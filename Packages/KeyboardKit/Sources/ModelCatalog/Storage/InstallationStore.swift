import Foundation

public actor InstallationStore {
  private let ledgerURL: URL
  private let fileManager: FileManager
  private var ledger: InstallationLedger
  private var loaded: Bool = false
  private var continuations: [UUID: AsyncStream<InstallationSnapshot>.Continuation] = [:]

  public init(ledgerURL: URL, fileManager: FileManager = .default) {
    self.ledgerURL = ledgerURL
    self.fileManager = fileManager
    self.ledger = .empty
  }

  public static func `default`(in directory: URL) -> InstallationStore {
    InstallationStore(ledgerURL: directory.appendingPathComponent("installations.json"))
  }

  private func loadIfNeeded() {
    guard !loaded else { return }
    loaded = true
    guard fileManager.fileExists(atPath: ledgerURL.path),
          let data = try? Data(contentsOf: ledgerURL) else {
      return
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    if let decoded = try? decoder.decode(InstallationLedger.self, from: data) {
      ledger = decoded
    }
  }

  private func persist() throws {
    let parent = ledgerURL.deletingLastPathComponent()
    if !fileManager.fileExists(atPath: parent.path) {
      try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
    }
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(ledger)
    let tmp = ledgerURL.appendingPathExtension("tmp")
    try data.write(to: tmp, options: .atomic)
    if fileManager.fileExists(atPath: ledgerURL.path) {
      _ = try fileManager.replaceItemAt(ledgerURL, withItemAt: tmp)
    } else {
      try fileManager.moveItem(at: tmp, to: ledgerURL)
    }
    emitSnapshot()
  }

  public func snapshot() -> InstallationSnapshot {
    loadIfNeeded()
    return InstallationSnapshot(records: ledger.records, activeModelID: ledger.activeModelID)
  }

  public func record(for id: ModelIdentifier) -> InstallationRecord? {
    loadIfNeeded()
    return ledger.records[id]
  }

  public func allRecords() -> [InstallationRecord] {
    loadIfNeeded()
    return ledger.records.values.sorted { $0.specSnapshot.tier.sortOrder < $1.specSnapshot.tier.sortOrder }
  }

  public func installedModelIDs() -> Set<ModelIdentifier> {
    loadIfNeeded()
    return Set(ledger.records.keys)
  }

  public func activeModelID() -> ModelIdentifier? {
    loadIfNeeded()
    return ledger.activeModelID
  }

  @discardableResult
  public func upsert(_ record: InstallationRecord) throws -> InstallationRecord {
    loadIfNeeded()
    ledger.records[record.modelID] = record
    try persist()
    return record
  }

  public func touch(_ id: ModelIdentifier, at date: Date = Date()) throws {
    loadIfNeeded()
    guard var record = ledger.records[id] else { return }
    record.lastUsedAt = date
    ledger.records[id] = record
    try persist()
  }

  public func setActive(_ id: ModelIdentifier?) throws {
    loadIfNeeded()
    ledger.activeModelID = id
    var updated: [ModelIdentifier: InstallationRecord] = [:]
    for (key, value) in ledger.records {
      var mutable = value
      mutable.isActive = (key == id)
      updated[key] = mutable
    }
    ledger.records = updated
    try persist()
  }

  @discardableResult
  public func remove(_ id: ModelIdentifier) throws -> Bool {
    loadIfNeeded()
    guard ledger.records.removeValue(forKey: id) != nil else { return false }
    if ledger.activeModelID == id {
      ledger.activeModelID = nil
    }
    try persist()
    return true
  }

  public func events() -> AsyncStream<InstallationSnapshot> {
    loadIfNeeded()
    let token = UUID()
    let current = InstallationSnapshot(records: ledger.records, activeModelID: ledger.activeModelID)
    let (stream, continuation) = AsyncStream<InstallationSnapshot>.makeStream()
    continuations[token] = continuation
    continuation.yield(current)
    continuation.onTermination = { [weak self] _ in
      Task { [weak self] in
        await self?.removeContinuation(token)
      }
    }
    return stream
  }

  private func removeContinuation(_ token: UUID) {
    continuations.removeValue(forKey: token)
  }

  private func emitSnapshot() {
    let snap = InstallationSnapshot(records: ledger.records, activeModelID: ledger.activeModelID)
    for continuation in continuations.values {
      continuation.yield(snap)
    }
  }
}

public struct InstallationSnapshot: Sendable, Equatable {
  public let records: [ModelIdentifier: InstallationRecord]
  public let activeModelID: ModelIdentifier?

  public var installedCount: Int { records.count }

  public var totalBytes: Int64 {
    records.values.reduce(0) { $0 + $1.byteSize }
  }

  public func isInstalled(_ id: ModelIdentifier) -> Bool {
    records[id] != nil
  }
}
