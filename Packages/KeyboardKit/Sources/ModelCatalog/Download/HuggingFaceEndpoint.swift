import Foundation

public struct HuggingFaceEndpoint: Sendable {
  public let baseURL: URL
  public let accessToken: String?
  public let userAgent: String

  public init(
    baseURL: URL = URL(string: "https://huggingface.co")!,
    accessToken: String? = nil,
    userAgent: String = "KeyboardApp/1.0 (+parakeet)"
  ) {
    self.baseURL = baseURL
    self.accessToken = accessToken
    self.userAgent = userAgent
  }

  public func artifactURL(repository: String, revision: String, path: String) -> URL {
    var url = baseURL
      .appendingPathComponent(repository)
      .appendingPathComponent("resolve")
      .appendingPathComponent(revision)
    for segment in path.split(separator: "/", omittingEmptySubsequences: false) {
      url.appendPathComponent(String(segment))
    }
    return url
  }

  public func request(
    repository: String,
    revision: String,
    path: String,
    rangeStart: Int64? = nil
  ) -> URLRequest {
    var request = URLRequest(url: artifactURL(repository: repository, revision: revision, path: path))
    request.httpMethod = "GET"
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    request.setValue("identity", forHTTPHeaderField: "Accept-Encoding")
    if let accessToken {
      request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
    if let rangeStart, rangeStart > 0 {
      request.setValue("bytes=\(rangeStart)-", forHTTPHeaderField: "Range")
    }
    request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    return request
  }
}
