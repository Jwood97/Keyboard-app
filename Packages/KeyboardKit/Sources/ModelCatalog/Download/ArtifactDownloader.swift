import CryptoKit
import Foundation

actor ArtifactDownloader {
  struct ProgressTick: Sendable {
    let bytesWritten: Int64
    let bytesTotal: Int64
  }

  private let session: URLSession
  private let endpoint: HuggingFaceEndpoint
  private let storage: ModelStorage

  init(session: URLSession, endpoint: HuggingFaceEndpoint, storage: ModelStorage) {
    self.session = session
    self.endpoint = endpoint
    self.storage = storage
  }

  func download(
    artifact: ModelArtifact,
    in spec: ModelSpec,
    onProgress: @Sendable @escaping (ProgressTick) async -> Void
  ) async throws {
    let finalURL = storage.artifactURL(for: artifact, in: spec)
    if FileManager.default.fileExists(atPath: finalURL.path) {
      let size = storage.byteSize(at: finalURL)
      if size >= artifact.expectedByteSize {
        await onProgress(ProgressTick(bytesWritten: size, bytesTotal: max(size, artifact.expectedByteSize)))
        try verifyIfNeeded(artifact: artifact, url: finalURL)
        return
      }
      try? FileManager.default.removeItem(at: finalURL)
    }

    let parent = finalURL.deletingLastPathComponent()
    if !FileManager.default.fileExists(atPath: parent.path) {
      try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
    }

    let request = endpoint.request(
      repository: spec.repository,
      revision: spec.revision,
      path: artifact.remotePath
    )

    let expectedBytes = artifact.expectedByteSize
    let delegate = DownloadProgressDelegate { bytesWritten, totalBytes in
      let total = totalBytes > 0 ? totalBytes : expectedBytes
      Task { await onProgress(ProgressTick(bytesWritten: bytesWritten, bytesTotal: total)) }
    }

    let tempURL: URL
    let response: URLResponse
    do {
      (tempURL, response) = try await session.download(for: request, delegate: delegate)
    } catch is CancellationError {
      throw ModelDownloadError.cancelled
    } catch let urlError as URLError where urlError.code == .cancelled {
      throw ModelDownloadError.cancelled
    } catch {
      throw ModelDownloadError.networkFailure(underlying: error.localizedDescription)
    }

    guard let http = response as? HTTPURLResponse else {
      throw ModelDownloadError.invalidResponse
    }
    guard (200..<300).contains(http.statusCode) else {
      try? FileManager.default.removeItem(at: tempURL)
      throw ModelDownloadError.httpStatus(http.statusCode)
    }

    if FileManager.default.fileExists(atPath: finalURL.path) {
      try FileManager.default.removeItem(at: finalURL)
    }
    try FileManager.default.moveItem(at: tempURL, to: finalURL)
    try verifyIfNeeded(artifact: artifact, url: finalURL)

    let written = storage.byteSize(at: finalURL)
    await onProgress(ProgressTick(bytesWritten: written, bytesTotal: max(written, expectedBytes)))
  }

  private func verifyIfNeeded(artifact: ModelArtifact, url: URL) throws {
    guard let expected = artifact.sha256 else { return }
    let actual = try Self.sha256Hex(of: url)
    guard actual.caseInsensitiveCompare(expected) == .orderedSame else {
      try? FileManager.default.removeItem(at: url)
      throw ModelDownloadError.verificationFailed(artifact: artifact.remotePath, reason: "SHA-256 mismatch")
    }
  }

  static func sha256Hex(of url: URL) throws -> String {
    let handle = try FileHandle(forReadingFrom: url)
    defer { try? handle.close() }
    var hasher = SHA256()
    while true {
      let chunk = handle.readData(ofLength: 1024 * 1024)
      if chunk.isEmpty { break }
      hasher.update(data: chunk)
    }
    let digest = hasher.finalize()
    return digest.map { String(format: "%02x", $0) }.joined()
  }
}

final class DownloadProgressDelegate: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
  private let onProgress: @Sendable (Int64, Int64) -> Void

  init(onProgress: @escaping @Sendable (Int64, Int64) -> Void) {
    self.onProgress = onProgress
  }

  func urlSession(
    _ session: URLSession,
    downloadTask: URLSessionDownloadTask,
    didWriteData bytesWritten: Int64,
    totalBytesWritten: Int64,
    totalBytesExpectedToWrite: Int64
  ) {
    onProgress(totalBytesWritten, totalBytesExpectedToWrite)
  }

  func urlSession(
    _ session: URLSession,
    downloadTask: URLSessionDownloadTask,
    didFinishDownloadingTo location: URL
  ) {}
}
