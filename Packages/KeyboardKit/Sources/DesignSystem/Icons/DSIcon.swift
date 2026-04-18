import Foundation

public struct DSIcon: Sendable, Hashable, Identifiable {
  public let rawName: String
  public let availableWeights: DSIconWeightSet

  public var id: String { self.rawName }

  public init(rawName: String, availableWeights: DSIconWeightSet) {
    self.rawName = rawName
    self.availableWeights = availableWeights
  }

  public func resolvedAssetName(weight: DSIconWeight) -> String {
    let resolvedWeight = self.availableWeights.contains(weight) ? weight : self.fallbackWeight(for: weight)
    switch resolvedWeight {
      case .regular: return self.rawName
      case .fill: return "\(self.rawName)-fill"
    }
  }

  private func fallbackWeight(for weight: DSIconWeight) -> DSIconWeight {
    switch weight {
      case .regular:
        return self.availableWeights.contains(.fill) ? .fill : .regular
      case .fill:
        return self.availableWeights.contains(.regular) ? .regular : .fill
    }
  }
}
