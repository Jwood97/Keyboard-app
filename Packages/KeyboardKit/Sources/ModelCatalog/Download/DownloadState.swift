import Foundation

public enum DownloadState: Sendable, Equatable {
  case notDownloaded
  case queued
  case downloading(DownloadProgress)
  case paused(DownloadProgress)
  case verifying
  case installed(InstallationRecord)
  case failed(ModelDownloadError)

  public var isTerminal: Bool {
    switch self {
      case .installed, .failed, .notDownloaded: return true
      default: return false
    }
  }

  public var isActive: Bool {
    switch self {
      case .queued, .downloading, .verifying: return true
      default: return false
    }
  }

  public var progress: DownloadProgress? {
    switch self {
      case let .downloading(progress), let .paused(progress):
        return progress
      default: return nil
    }
  }

  public var fractionCompleted: Double {
    switch self {
      case let .downloading(p), let .paused(p): return p.fractionCompleted
      case .verifying: return 0.99
      case .installed: return 1
      default: return 0
    }
  }

  public static func == (lhs: DownloadState, rhs: DownloadState) -> Bool {
    switch (lhs, rhs) {
      case (.notDownloaded, .notDownloaded): return true
      case (.queued, .queued): return true
      case let (.downloading(a), .downloading(b)): return a == b
      case let (.paused(a), .paused(b)): return a == b
      case (.verifying, .verifying): return true
      case let (.installed(a), .installed(b)): return a == b
      case let (.failed(a), .failed(b)): return a == b
      default: return false
    }
  }
}

public struct DownloadEvent: Sendable, Equatable {
  public let modelID: ModelIdentifier
  public let state: DownloadState
  public let timestamp: Date

  public init(modelID: ModelIdentifier, state: DownloadState, timestamp: Date = Date()) {
    self.modelID = modelID
    self.state = state
    self.timestamp = timestamp
  }
}
