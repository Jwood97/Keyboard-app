import Foundation

public actor ModelDownloadManager {
  public struct Configuration: Sendable {
    public var maxConcurrentArtifacts: Int
    public var requestTimeout: TimeInterval
    public var resourceTimeout: TimeInterval
    public var allowsCellular: Bool
    public var waitsForConnectivity: Bool

    public init(
      maxConcurrentArtifacts: Int = 2,
      requestTimeout: TimeInterval = 60,
      resourceTimeout: TimeInterval = 60 * 60 * 4,
      allowsCellular: Bool = true,
      waitsForConnectivity: Bool = true
    ) {
      self.maxConcurrentArtifacts = maxConcurrentArtifacts
      self.requestTimeout = requestTimeout
      self.resourceTimeout = resourceTimeout
      self.allowsCellular = allowsCellular
      self.waitsForConnectivity = waitsForConnectivity
    }

    public static let `default` = Configuration()
  }

  private let storage: ModelStorage
  private let installations: InstallationStore
  private let endpoint: HuggingFaceEndpoint
  private let downloader: ArtifactDownloader
  private let configuration: Configuration
  private let catalog: [ModelIdentifier: ModelSpec]

  private var tasks: [ModelIdentifier: ModelDownloadTask] = [:]
  private var continuations: [ModelIdentifier: [UUID: AsyncStream<DownloadEvent>.Continuation]] = [:]
  private var broadcastContinuations: [UUID: AsyncStream<DownloadEvent>.Continuation] = [:]

  public init(
    storage: ModelStorage,
    installations: InstallationStore,
    endpoint: HuggingFaceEndpoint = HuggingFaceEndpoint(),
    configuration: Configuration = .default,
    catalog: [ModelSpec] = ParakeetCatalog.all,
    session: URLSession? = nil
  ) {
    self.storage = storage
    self.installations = installations
    self.endpoint = endpoint
    self.configuration = configuration
    self.catalog = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0) })

    let urlSession: URLSession = {
      if let session { return session }
      let config = URLSessionConfiguration.default
      config.timeoutIntervalForRequest = configuration.requestTimeout
      config.timeoutIntervalForResource = configuration.resourceTimeout
      config.waitsForConnectivity = configuration.waitsForConnectivity
      config.allowsCellularAccess = configuration.allowsCellular
      config.httpMaximumConnectionsPerHost = max(1, configuration.maxConcurrentArtifacts)
      config.requestCachePolicy = .reloadIgnoringLocalCacheData
      return URLSession(configuration: config)
    }()

    self.downloader = ArtifactDownloader(session: urlSession, endpoint: endpoint, storage: storage)
  }

  public nonisolated func catalogSpecs() -> [ModelSpec] {
    ParakeetCatalog.all
  }

  public func spec(for id: ModelIdentifier) -> ModelSpec? {
    catalog[id]
  }

  public func state(for id: ModelIdentifier) async -> DownloadState {
    if let task = tasks[id] { return task.state }
    if let record = await installations.record(for: id) {
      return .installed(record)
    }
    return .notDownloaded
  }

  public func events(for id: ModelIdentifier) async -> AsyncStream<DownloadEvent> {
    let token = UUID()
    let currentState = await state(for: id)
    let (stream, continuation) = AsyncStream<DownloadEvent>.makeStream()
    continuations[id, default: [:]][token] = continuation
    continuation.yield(DownloadEvent(modelID: id, state: currentState))
    continuation.onTermination = { [weak self] _ in
      Task { [weak self] in
        await self?.removeContinuation(id: id, token: token)
      }
    }
    return stream
  }

  public func allEvents() -> AsyncStream<DownloadEvent> {
    let token = UUID()
    let snapshot = tasks.map { ($0.key, $0.value.state) }
    let (stream, continuation) = AsyncStream<DownloadEvent>.makeStream()
    broadcastContinuations[token] = continuation
    for (id, state) in snapshot {
      continuation.yield(DownloadEvent(modelID: id, state: state))
    }
    continuation.onTermination = { [weak self] _ in
      Task { [weak self] in
        await self?.removeBroadcast(token: token)
      }
    }
    return stream
  }

  @discardableResult
  public func download(_ id: ModelIdentifier) async throws -> InstallationRecord {
    guard let spec = catalog[id] else { throw ModelDownloadError.unknownModel(id) }
    if let existing = tasks[id] {
      throw ModelDownloadError.alreadyInProgress(existing.spec.id)
    }

    try storage.prepare()
    if !storage.hasEnoughSpace(for: spec) {
      throw ModelDownloadError.notEnoughDiskSpace(
        required: spec.requiredByteSize,
        available: storage.availableCapacity()
      )
    }
    _ = try storage.ensureModelDirectory(for: spec)

    let task = ModelDownloadTask(spec: spec)
    tasks[id] = task
    emit(.init(modelID: id, state: .queued))

    for artifact in spec.artifacts {
      let existing = storage.byteSize(at: storage.artifactURL(for: artifact, in: spec))
      if existing >= artifact.expectedByteSize {
        task.bytesPerArtifact[artifact.remotePath] = existing
      } else {
        let partial = storage.byteSize(at: storage.partialURL(for: artifact, in: spec))
        task.bytesPerArtifact[artifact.remotePath] = min(partial, artifact.expectedByteSize)
      }
    }

    let running = Task {
      try await self.runDownload(task: task)
    }
    task.task = running

    do {
      try await running.value
    } catch {
      let paused = tasks[id]?.isPauseRequested == true
      let taskRef = tasks[id]
      tasks.removeValue(forKey: id)
      let downloadError: ModelDownloadError
      if let mapped = error as? ModelDownloadError {
        downloadError = mapped
      } else if error is CancellationError {
        downloadError = .cancelled
      } else {
        downloadError = .networkFailure(underlying: error.localizedDescription)
      }
      if paused, let taskRef {
        let progress = buildProgress(for: taskRef)
        emit(.init(modelID: id, state: .paused(progress)))
      } else {
        emit(.init(modelID: id, state: .failed(downloadError)))
      }
      throw downloadError
    }

    guard let record = await installations.record(for: id) else {
      throw ModelDownloadError.storageFailure("Installation record missing")
    }
    tasks.removeValue(forKey: id)
    emit(.init(modelID: id, state: .installed(record)))
    return record
  }

  public func cancel(_ id: ModelIdentifier) {
    guard let task = tasks[id] else { return }
    task.task?.cancel()
  }

  public func pause(_ id: ModelIdentifier) {
    guard let task = tasks[id] else { return }
    task.isPauseRequested = true
    task.task?.cancel()
  }

  @discardableResult
  public func resume(_ id: ModelIdentifier) async throws -> InstallationRecord {
    try await download(id)
  }

  @discardableResult
  public func delete(_ id: ModelIdentifier) async throws -> Bool {
    cancel(id)
    let removed = try storage.removeModel(id)
    _ = try await installations.remove(id)
    emit(.init(modelID: id, state: .notDownloaded))
    return removed
  }

  public func verifyAll() async -> [ModelIdentifier: Bool] {
    var results: [ModelIdentifier: Bool] = [:]
    for spec in catalog.values {
      results[spec.id] = storage.isFullyInstalled(spec)
    }
    return results
  }

  public func setActive(_ id: ModelIdentifier?) async throws {
    try await installations.setActive(id)
  }

  public func activeModelID() async -> ModelIdentifier? {
    await installations.activeModelID()
  }

  public func installedSpecs() async -> [ModelSpec] {
    await installations.allRecords().map(\.specSnapshot)
  }

  public func installationEvents() async -> AsyncStream<InstallationSnapshot> {
    await installations.events()
  }

  public func installationSnapshot() async -> InstallationSnapshot {
    await installations.snapshot()
  }

  public func touch(_ id: ModelIdentifier) async throws {
    try await installations.touch(id)
  }

  private func runDownload(task: ModelDownloadTask) async throws {
    let spec = task.spec
    task.startedAt = Date()
    task.sampler = TransferRateSampler()
    task.state = .downloading(buildProgress(for: task))
    emit(.init(modelID: spec.id, state: task.state))

    let concurrency = max(1, configuration.maxConcurrentArtifacts)
    var remaining = spec.artifacts
    try await withThrowingTaskGroup(of: Void.self) { group in
      var inFlight = 0
      while !remaining.isEmpty || inFlight > 0 {
        while inFlight < concurrency, !remaining.isEmpty {
          let artifact = remaining.removeFirst()
          inFlight += 1
          group.addTask { [weak self, weak task] in
            guard let self, let task else { return }
            try await self.downloader.download(artifact: artifact, in: spec) { tick in
              await self.handleTick(task: task, artifact: artifact, tick: tick)
            }
          }
        }
        _ = try await group.next()
        inFlight -= 1
      }
    }

    task.state = .verifying
    emit(.init(modelID: spec.id, state: task.state))

    guard storage.isFullyInstalled(spec) else {
      throw ModelDownloadError.verificationFailed(artifact: spec.id.rawValue, reason: "Missing artifacts after download")
    }

    let installedBytes = storage.occupiedBytes(for: spec.id)
    let record = InstallationRecord(
      modelID: spec.id,
      specSnapshot: spec,
      installedAt: Date(),
      lastUsedAt: nil,
      byteSize: installedBytes,
      revisionInstalled: spec.revision,
      isActive: false
    )
    _ = try await installations.upsert(record)
  }

  private func handleTick(task: ModelDownloadTask, artifact: ModelArtifact, tick: ArtifactDownloader.ProgressTick) {
    task.bytesPerArtifact[artifact.remotePath] = tick.bytesWritten
    task.currentArtifactRemotePath = artifact.remotePath
    task.sampler.record(bytes: task.totalBytesCompleted)
    let progress = buildProgress(for: task)
    task.state = .downloading(progress)
    emit(.init(modelID: task.spec.id, state: task.state))
  }

  private func buildProgress(for task: ModelDownloadTask) -> DownloadProgress {
    let spec = task.spec
    let totalBytes = spec.requiredByteSize
    let completed = min(totalBytes, task.totalBytesCompleted)
    let currentArtifact: ArtifactProgress? = {
      guard let remotePath = task.currentArtifactRemotePath,
            let artifact = spec.artifacts.first(where: { $0.remotePath == remotePath }) else {
        return nil
      }
      let bytes = task.bytesPerArtifact[remotePath] ?? 0
      return ArtifactProgress(
        remotePath: remotePath,
        bytesCompleted: bytes,
        bytesTotal: artifact.expectedByteSize
      )
    }()
    return DownloadProgress(
      modelID: spec.id,
      bytesCompleted: completed,
      bytesTotal: totalBytes,
      artifactsCompleted: task.artifactsCompleted,
      artifactsTotal: spec.artifacts.count,
      bytesPerSecond: task.sampler.bytesPerSecond,
      currentArtifact: currentArtifact,
      startedAt: task.startedAt,
      updatedAt: Date()
    )
  }

  private func emit(_ event: DownloadEvent) {
    if let entries = continuations[event.modelID] {
      for continuation in entries.values {
        continuation.yield(event)
      }
    }
    for continuation in broadcastContinuations.values {
      continuation.yield(event)
    }
  }

  private func removeContinuation(id: ModelIdentifier, token: UUID) {
    continuations[id]?.removeValue(forKey: token)
    if continuations[id]?.isEmpty == true {
      continuations.removeValue(forKey: id)
    }
  }

  private func removeBroadcast(token: UUID) {
    broadcastContinuations.removeValue(forKey: token)
  }
}

