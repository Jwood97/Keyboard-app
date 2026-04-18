import Foundation

struct TransferRateSampler: Sendable {
  private struct Sample: Sendable {
    let timestamp: Date
    let bytes: Int64
  }

  private var samples: [Sample] = []
  private let window: TimeInterval
  private let maxSamples: Int

  init(window: TimeInterval = 3.0, maxSamples: Int = 64) {
    self.window = window
    self.maxSamples = maxSamples
  }

  mutating func record(bytes: Int64, at date: Date = Date()) {
    samples.append(Sample(timestamp: date, bytes: bytes))
    let cutoff = date.addingTimeInterval(-window)
    while let first = samples.first, first.timestamp < cutoff {
      samples.removeFirst()
    }
    if samples.count > maxSamples {
      samples.removeFirst(samples.count - maxSamples)
    }
  }

  var bytesPerSecond: Double {
    guard let first = samples.first, let last = samples.last else { return 0 }
    let interval = last.timestamp.timeIntervalSince(first.timestamp)
    guard interval > 0 else { return 0 }
    let deltaBytes = Double(last.bytes - first.bytes)
    guard deltaBytes > 0 else { return 0 }
    return deltaBytes / interval
  }

  mutating func reset() {
    samples.removeAll(keepingCapacity: true)
  }
}
