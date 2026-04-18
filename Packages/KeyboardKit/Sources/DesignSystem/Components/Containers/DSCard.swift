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
  private let action: (() -> Void)?
  private let accessibilityLabel: String?
  private let accessibilityHint: String?
  private let content: Content
  @Environment(\.isEnabled) private var isEnabled: Bool

  public init(
    style: DSCardStyle = .elevated,
    padding: CGFloat = DSSpacing.lg,
    radius: CGFloat = DSRadius.lg,
    action: (() -> Void)? = nil,
    accessibilityLabel: String? = nil,
    accessibilityHint: String? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.style = style
    self.padding = padding
    self.radius = radius
    self.action = action
    self.accessibilityLabel = accessibilityLabel
    self.accessibilityHint = accessibilityHint
    self.content = content()
  }

  public var body: some View {
    if let action = self.action {
      Button {
        DSHaptics.selection()
        action()
      } label: {
        self.cardBody
      }
      .buttonStyle(DSPressScaleStyle(pressedScale: 0.985, pressedOpacity: 0.96))
      .accessibilityElement(children: self.accessibilityLabel == nil ? .combine : .ignore)
      .modifier(OptionalAccessibilityLabel(label: self.accessibilityLabel))
      .modifier(OptionalAccessibilityHint(hint: self.accessibilityHint))
      .accessibilityAddTraits(.isButton)
      .opacity(self.isEnabled ? 1 : 0.55)
    } else {
      self.cardBody
    }
  }

  private var cardBody: some View {
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
        return DSColor.Accent.primarySoft.opacity(0.55)
    }
  }

  private var borderColor: Color {
    switch self.style {
      case .plain:
        return DSColor.Border.subtle
      case .elevated:
        return DSColor.Border.subtle.opacity(0.82)
      case .bordered:
        return DSColor.Border.default
      case .accent:
        return DSColor.Accent.primary.opacity(0.18)
    }
  }

  private var borderWidth: CGFloat {
    switch self.style {
      case .plain, .elevated, .bordered, .accent:
        return 1
    }
  }

  private var shadow: DSShadow {
    switch self.style {
      case .elevated:
        return DSElevation.xs
      case .plain, .bordered, .accent:
        return DSElevation.none
    }
  }
}

private struct OptionalAccessibilityLabel: ViewModifier {
  let label: String?

  func body(content: Content) -> some View {
    if let label = self.label {
      content.accessibilityLabel(label)
    } else {
      content
    }
  }
}

private struct OptionalAccessibilityHint: ViewModifier {
  let hint: String?

  func body(content: Content) -> some View {
    if let hint = self.hint {
      content.accessibilityHint(hint)
    } else {
      content
    }
  }
}
