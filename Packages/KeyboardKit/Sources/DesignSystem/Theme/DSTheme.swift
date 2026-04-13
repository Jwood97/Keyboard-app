import SwiftUI

public enum DSTheme {
  public typealias Color = DSColor
  public typealias Typography = DSTypography
  public typealias TextStyle = DSTextStyle
  public typealias Spacing = DSSpacing
  public typealias Radius = DSRadius
  public typealias Elevation = DSElevation
  public typealias Motion = DSMotion
  public typealias Icon = DSIconSize
}

public struct DSBackground: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .background(DSColor.Background.canvas.ignoresSafeArea())
  }
}

public extension View {
  func dsBackground() -> some View {
    self.modifier(DSBackground())
  }
}
