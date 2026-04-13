import SwiftUI

public struct DSShadow: Sendable {
  public let color: Color
  public let radius: CGFloat
  public let x: CGFloat
  public let y: CGFloat

  public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
    self.color = color
    self.radius = radius
    self.x = x
    self.y = y
  }
}

public enum DSElevation {
  public static let none = DSShadow(color: .clear, radius: 0)
  public static let xs = DSShadow(
    color: Color.dynamic(
      light: Palette.Sand.shade950.opacity(0.06),
      dark: Palette.Neutral.pureBlack.opacity(0.35)
    ),
    radius: 4,
    y: 2
  )
  public static let sm = DSShadow(
    color: Color.dynamic(
      light: Palette.Sand.shade950.opacity(0.08),
      dark: Palette.Neutral.pureBlack.opacity(0.40)
    ),
    radius: 10,
    y: 4
  )
  public static let md = DSShadow(
    color: Color.dynamic(
      light: Palette.Sand.shade950.opacity(0.10),
      dark: Palette.Neutral.pureBlack.opacity(0.45)
    ),
    radius: 18,
    y: 8
  )
  public static let lg = DSShadow(
    color: Color.dynamic(
      light: Palette.Sand.shade950.opacity(0.12),
      dark: Palette.Neutral.pureBlack.opacity(0.50)
    ),
    radius: 28,
    y: 14
  )
  public static let xl = DSShadow(
    color: Color.dynamic(
      light: Palette.Sand.shade950.opacity(0.18),
      dark: Palette.Neutral.pureBlack.opacity(0.55)
    ),
    radius: 44,
    y: 22
  )
  public static let accentGlow = DSShadow(
    color: Palette.Matcha.shade500.opacity(0.35),
    radius: 24,
    y: 12
  )
}

public extension View {
  func dsShadow(_ shadow: DSShadow) -> some View {
    self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
  }
}
