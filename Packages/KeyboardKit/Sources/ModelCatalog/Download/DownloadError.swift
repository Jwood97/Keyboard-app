import Foundation

public enum ModelDownloadError: Error, Sendable, LocalizedError, Equatable {
  case notEnoughDiskSpace(required: Int64, available: Int64?)
  case networkFailure(underlying: String)
  case httpStatus(Int)
  case invalidResponse
  case cancelled
  case verificationFailed(artifact: String, reason: String)
  case unknownModel(ModelIdentifier)
  case alreadyInProgress(ModelIdentifier)
  case storageFailure(String)

  public var errorDescription: String? {
    switch self {
      case let .notEnoughDiskSpace(required, available):
        let req = ByteFormatting.human(required)
        let av = available.map(ByteFormatting.human) ?? "unknown"
        return "Not enough space. Needs \(req), available \(av)."
      case let .networkFailure(message):
        return "Network error: \(message)"
      case let .httpStatus(code):
        return "Server returned status \(code)."
      case .invalidResponse:
        return "Invalid response from server."
      case .cancelled:
        return "Download cancelled."
      case let .verificationFailed(artifact, reason):
        return "Verification failed for \(artifact): \(reason)"
      case let .unknownModel(id):
        return "Unknown model: \(id.rawValue)"
      case let .alreadyInProgress(id):
        return "Download already running for \(id.rawValue)."
      case let .storageFailure(message):
        return "Storage error: \(message)"
    }
  }
}
