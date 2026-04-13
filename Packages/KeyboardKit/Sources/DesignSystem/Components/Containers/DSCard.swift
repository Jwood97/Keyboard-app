import SwiftUI

public enum DSCardStyle: Sendable {
  case plain
  case elevated
  case bordered
  case accent
}

public struct DSCard<Content: View>: View {
  private let style: DSCardStyle
  private let padding: CGFloat
  private let radius: CGFloat
  private let content: Content

  public init(
    style: DSCardStyle = .elevated,
    padding: CGFloat = DSSpacing.lg,
    radius: CGFloat = DSRadius.card,
    @ViewBuilder content: () -> Content
  ) {
    self.style = style
    self.padding = padding
    self.radius = radius
    self.content = content()
  }

  public var body: some View {
    self.content
      .padding(self.padding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: self.radius, style: .continuous)
          .fill(self.fill)
      )
      .overlay(
        RoundedRectangle(cornerRadius: self.radius, style: .continuous)
          .strokeBorder(self.borderColor, lineWidth: self.borderWidth)
      )
      .dsShadow(self.shadow)
  }

  private var fill: Color {
    switch self.style {
      case .plain:
        return DSColor.Background.surface
      case .elevated:
        return DSColor.Background.surface
      case .bordered:
        return DSColor.Background.surface
      case .accent:
        return DSColor.Accent.primarySoft
    }
  }

  private var borderColor: Color {
    switch self.style {
      case .bordered:
        return DSColor.Border.subtle
      case .accent:
        return DSColor.Accent.primary.opacity(0.35)
      default:
        return .clear
    }
  }

  private var borderWidth: CGFloat {
    switch self.style {
      case .bordered, .accent:
        return 1
      default:
        return 0
    }
  }

  private var shadow: DSShadow {
    switch self.style {
      case .elevated:
        return DSElevation.sm
      case .plain, .bordered, .accent:
        return DSElevation.none
    }
  }
}
