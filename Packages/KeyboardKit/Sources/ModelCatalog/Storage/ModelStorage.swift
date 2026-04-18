import Foundation

public struct ModelStorage: Sendable {
  public struct Configuration: Sendable {
    public let rootDirectory: URL
    public let temporaryDirectory: URL
    public let appGroupIdentifier: String?

    public init(rootDirectory: URL, temporaryDirectory: URL, appGroupIdentifier: String? = nil) {
      self.rootDirectory = rootDirectory
      self.temporaryDirectory = temporaryDirectory
      self.appGroupIdentifier = appGroupIdentifier
    }

    public static func appGroup(_ identifier: String) -> Configuration? {
      let fileManager = FileManager.default
      guard let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
        return nil
      }
      let root = container.appendingPathComponent("Models", isDirectory: true)
      let tmp = container.appendingPathComponent("ModelsTmp", isDirectory: true)
      return Configuration(rootDirectory: root, temporaryDirectory: tmp, appGroupIdentifier: identifier)
    }

    public static func applicationSupport(subdirectory: String = "Models") -> Configuration {
      let fileManager = FileManager.default
      let support = (try? fileManager.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )) ?? fileManager.temporaryDirectory
      let root = support.appendingPathComponent(subdirectory, isDirectory: true)
      let tmp = support.appendingPathComponent("\(subdirectory)Tmp", isDirectory: true)
      return Configuration(rootDirectory: root, temporaryDirectory: tmp, appGroupIdentifier: nil)
    }
  }

  public let configuration: Configuration
  private let fileManager: FileManager

  public init(configuration: Configuration, fileManager: FileManager = .default) {
    self.configuration = configuration
    self.fileManager = fileManager
  }

  public func prepare() throws {
    try fileManager.createDirectory(at: configuration.rootDirectory, withIntermediateDirectories: true)
    try fileManager.createDirectory(at: configuration.temporaryDirectory, withIntermediateDirectories: true)
  }

  public func modelDirectory(for id: ModelIdentifier) -> URL {
    configuration.rootDirectory.appendingPathComponent(id.rawValue, isDirectory: true)
  }

  public func artifactURL(for artifact: ModelArtifact, in spec: ModelSpec) -> URL {
    modelDirectory(for: spec.id).appendingPathComponent(artifact.localRelativePath)
  }

  public func partialURL(for artifact: ModelArtifact, in spec: ModelSpec) -> URL {
    let sanitized = artifact.localRelativePath.replacingOccurrences(of: "/", with: "_")
    return configuration.temporaryDirectory
      .appendingPathComponent("\(spec.id.rawValue)_\(sanitized).part")
  }

  public func ensureModelDirectory(for spec: ModelSpec) throws -> URL {
    let dir = modelDirectory(for: spec.id)
    try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
    for artifact in spec.artifacts {
      let artifactURL = artifactURL(for: artifact, in: spec)
      let parent = artifactURL.deletingLastPathComponent()
      if !fileManager.fileExists(atPath: parent.path) {
        try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
      }
    }
    return dir
  }

  public func byteSize(at url: URL) -> Int64 {
    guard let values = try? url.resourceValues(forKeys: [.fileSizeKey]) else { return 0 }
    return Int64(values.fileSize ?? 0)
  }

  public func artifactExists(for artifact: ModelArtifact, in spec: ModelSpec) -> Bool {
    let url = artifactURL(for: artifact, in: spec)
    return fileManager.fileExists(atPath: url.path)
  }

  public func isFullyInstalled(_ spec: ModelSpec) -> Bool {
    spec.requiredArtifacts.allSatisfy { artifact in
      let url = artifactURL(for: artifact, in: spec)
      guard fileManager.fileExists(atPath: url.path) else { return false }
      let size = byteSize(at: url)
      return size >= artifact.expectedByteSize
    }
  }

  @discardableResult
  public func removeModel(_ id: ModelIdentifier) throws -> Bool {
    let dir = modelDirectory(for: id)
    guard fileManager.fileExists(atPath: dir.path) else { return false }
    try fileManager.removeItem(at: dir)
    return true
  }

  public func clearTemporary() {
    guard let items = try? fileManager.contentsOfDirectory(
      at: configuration.temporaryDirectory,
      includingPropertiesForKeys: nil
    ) else { return }
    for item in items {
      try? fileManager.removeItem(at: item)
    }
  }

  public func occupiedBytes(for id: ModelIdentifier) -> Int64 {
    let dir = modelDirectory(for: id)
    let keys: [URLResourceKey] = [.fileSizeKey, .isRegularFileKey]
    guard let enumerator = fileManager.enumerator(
      at: dir,
      includingPropertiesForKeys: keys,
      options: [.skipsHiddenFiles]
    ) else { return 0 }
    var total: Int64 = 0
    for case let url as URL in enumerator {
      guard let values = try? url.resourceValues(forKeys: Set(keys)) else { continue }
      if values.isRegularFile == true {
        total += Int64(values.fileSize ?? 0)
      }
    }
    return total
  }

  public func availableCapacity() -> Int64? {
    let values = try? configuration.rootDirectory.resourceValues(
      forKeys: [.volumeAvailableCapacityForImportantUsageKey]
    )
    return values?.volumeAvailableCapacityForImportantUsage
  }

  public func hasEnoughSpace(for spec: ModelSpec, headroom: Int64 = 128 * 1024 * 1024) -> Bool {
    guard let available = availableCapacity() else { return true }
    return available >= spec.requiredByteSize + headroom
  }
}
