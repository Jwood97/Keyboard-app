import Foundation

public struct InstallationRecord: Hashable, Sendable, Codable {
  public var modelID: ModelIdentifier
  public var specSnapshot: ModelSpec
  public var installedAt: Date
  public var lastUsedAt: Date?
  public var byteSize: Int64
  public var revisionInstalled: String
  public var isActive: Bool

  public init(
    modelID: ModelIdentifier,
    specSnapshot: ModelSpec,
    installedAt: Date,
    lastUsedAt: Date? = nil,
    byteSize: Int64,
    revisionInstalled: String,
    isActive: Bool = false
  ) {
    self.modelID = modelID
    self.specSnapshot = specSnapshot
    self.installedAt = installedAt
    self.lastUsedAt = lastUsedAt
    self.byteSize = byteSize
    self.revisionInstalled = revisionInstalled
    self.isActive = isActive
  }
}

struct InstallationLedger: Codable, Sendable {
  var version: Int
  var records: [ModelIdentifier: InstallationRecord]
  var activeModelID: ModelIdentifier?

  static let currentVersion = 1

  static var empty: InstallationLedger {
    InstallationLedger(version: currentVersion, records: [:], activeModelID: nil)
  }
}
