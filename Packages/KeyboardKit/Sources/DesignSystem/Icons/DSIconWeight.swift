import Foundation

public enum DSIconWeight: String, Sendable, CaseIterable, Hashable {
  case regular
  case fill
}

public struct DSIconWeightSet: OptionSet, Sendable, Hashable {
  public let rawValue: Int
  public init(rawValue: Int) { self.rawValue = rawValue }

  public static let regular = DSIconWeightSet(rawValue: 1 << 0)
  public static let fill = DSIconWeightSet(rawValue: 1 << 1)

  public static let regularOnly: DSIconWeightSet = .regular
  public static let fillOnly: DSIconWeightSet = .fill
  public static let all: DSIconWeightSet = [.regular, .fill]

  public func contains(_ weight: DSIconWeight) -> Bool {
    switch weight {
      case .regular: return (self.rawValue & DSIconWeightSet.regular.rawValue) != 0
      case .fill: return (self.rawValue & DSIconWeightSet.fill.rawValue) != 0
    }
  }
}
