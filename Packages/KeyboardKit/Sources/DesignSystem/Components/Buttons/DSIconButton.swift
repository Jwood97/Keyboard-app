import SwiftUI

public enum DSIconButtonStyle: Sendable {
  case filled
  case soft
  case ghost
  case outline
}

public struct DSIconButton: View {
  private let icon: DSIcon
  private let weight: DSIconWeight
  private let style: DSIconButtonStyle
  private let size: DSButtonSize
  private let tint: Color
  private let action: () -> Void
  @Environment(\.isEnabled) private var isEnabled: Bool

  public init(
    icon: DSIcon,
    weight: DSIconWeight = .regular,
    style: DSIconButtonStyle = .soft,
    size: DSButtonSize = .medium,
    tint: Color = DSColor.Accent.primary,
    action: @escaping () -> Void
  ) {
    self.icon = icon
    self.weight = weight
    self.style = style
    self.size = size
    self.tint = tint
    self.action = action
  }

  public var body: some View {
    Button {
      DSHaptics.impact(.light)
      self.action()
    } label: {
      DSIconView(
        self.icon,
        weight: self.weight,
        size: self.size.iconSize + 4,
        tint: self.foreground
      )
      .frame(width: self.size.height, height: self.size.height)
    }
    .buttonStyle(IconButtonStyle(
      style: self.style,
      tint: self.tint,
      isEnabled: self.isEnabled
    ))
  }

  private var foreground: Color {
    guard self.isEnabled else { return DSColor.Text.disabled }
    switch self.style {
      case .filled:
        return DSColor.Text.onAccent
      case .soft, .ghost, .outline:
        return self.tint
    }
  }
}

private struct IconButtonStyle: ButtonStyle {
  let style: DSIconButtonStyle
  let tint: Color
  let isEnabled: Bool

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background(
        Circle()
          .fill(self.background(pressed: configuration.isPressed))
      )
      .overlay(
        Circle()
          .strokeBorder(self.borderColor, lineWidth: self.borderWidth)
      )
      .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
      .animation(DSMotion.press, value: configuration.isPressed)
      .opacity(self.isEnabled ? 1 : 0.55)
  }

  private func background(pressed: Bool) -> Color {
    switch self.style {
      case .filled:
        return pressed ? self.tint.opacity(0.8) : self.tint
      case .soft:
        return pressed ? self.tint.opacity(0.28) : self.tint.opacity(0.16)
      case .ghost:
        return pressed ? DSColor.Background.raised : .clear
      case .outline:
        return pressed ? self.tint.opacity(0.08) : .clear
    }
  }

  private var borderColor: Color {
    switch self.style {
      case .outline:
        return self.tint.opacity(0.35)
      default:
        return .clear
    }
  }

  private var borderWidth: CGFloat {
    self.style == .outline ? 1 : 0
  }
}
