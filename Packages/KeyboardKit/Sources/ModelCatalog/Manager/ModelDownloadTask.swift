import Foundation

final class ModelDownloadTask: @unchecked Sendable {
  let spec: ModelSpec
  var task: Task<Void, Error>?
  var state: DownloadState
  var bytesPerArtifact: [String: Int64]
  var sampler: TransferRateSampler
  var startedAt: Date
  var currentArtifactRemotePath: String?
  var isPauseRequested: Bool

  init(spec: ModelSpec) {
    self.spec = spec
    self.task = nil
    self.state = .queued
    self.bytesPerArtifact = [:]
    self.sampler = TransferRateSampler()
    self.startedAt = Date()
    self.currentArtifactRemotePath = nil
    self.isPauseRequested = false
  }

  var totalBytesCompleted: Int64 {
    bytesPerArtifact.values.reduce(0, +)
  }

  var artifactsCompleted: Int {
    spec.artifacts.reduce(into: 0) { count, artifact in
      if let bytes = bytesPerArtifact[artifact.remotePath],
         bytes >= artifact.expectedByteSize {
        count += 1
      }
    }
  }
}
