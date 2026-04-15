import CoreGraphics

public enum DSOpacity {
  public static let hidden: Double = 0
  public static let faint: Double = 0.08
  public static let soft: Double = 0.16
  public static let muted: Double = 0.35
  public static let disabled: Double = 0.5
  public static let dim: Double = 0.7
  public static let strong: Double = 0.85
  public static let full: Double = 1.0
}

public enum DSZIndex {
  public static let base: Double = 0
  public static let raised: Double = 10
  public static let sticky: Double = 100
  public static let overlay: Double = 500
  public static let sheet: Double = 800
  public static let modal: Double = 900
  public static let toast: Double = 1000
  public static let tooltip: Double = 1100
}
