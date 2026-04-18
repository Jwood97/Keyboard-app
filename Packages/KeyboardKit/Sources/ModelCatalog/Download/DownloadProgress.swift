import Foundation

public struct ArtifactProgress: Hashable, Sendable {
  public let remotePath: String
  public let bytesCompleted: Int64
  public let bytesTotal: Int64

  public var fractionCompleted: Double {
    guard bytesTotal > 0 else { return 0 }
    return min(1, Double(bytesCompleted) / Double(bytesTotal))
  }

  public init(remotePath: String, bytesCompleted: Int64, bytesTotal: Int64) {
    self.remotePath = remotePath
    self.bytesCompleted = bytesCompleted
    self.bytesTotal = bytesTotal
  }
}

public struct DownloadProgress: Hashable, Sendable {
  public let modelID: ModelIdentifier
  public let bytesCompleted: Int64
  public let bytesTotal: Int64
  public let artifactsCompleted: Int
  public let artifactsTotal: Int
  public let bytesPerSecond: Double
  public let currentArtifact: ArtifactProgress?
  public let startedAt: Date
  public let updatedAt: Date

  public init(
    modelID: ModelIdentifier,
    bytesCompleted: Int64,
    bytesTotal: Int64,
    artifactsCompleted: Int,
    artifactsTotal: Int,
    bytesPerSecond: Double,
    currentArtifact: ArtifactProgress?,
    startedAt: Date,
    updatedAt: Date
  ) {
    self.modelID = modelID
    self.bytesCompleted = bytesCompleted
    self.bytesTotal = bytesTotal
    self.artifactsCompleted = artifactsCompleted
    self.artifactsTotal = artifactsTotal
    self.bytesPerSecond = bytesPerSecond
    self.currentArtifact = currentArtifact
    self.startedAt = startedAt
    self.updatedAt = updatedAt
  }

  public var fractionCompleted: Double {
    guard bytesTotal > 0 else { return 0 }
    return min(1, Double(bytesCompleted) / Double(bytesTotal))
  }

  public var percentCompleted: Int {
    Int((fractionCompleted * 100).rounded())
  }

  public var remainingBytes: Int64 {
    max(0, bytesTotal - bytesCompleted)
  }

  public var estimatedTimeRemaining: TimeInterval? {
    guard bytesPerSecond > 0 else { return nil }
    return Double(remainingBytes) / bytesPerSecond
  }

  public var humanReadableCompleted: String { ByteFormatting.human(bytesCompleted) }
  public var humanReadableTotal: String { ByteFormatting.human(bytesTotal) }
  public var humanReadableSpeed: String { ByteFormatting.humanRate(bytesPerSecond) }
}
