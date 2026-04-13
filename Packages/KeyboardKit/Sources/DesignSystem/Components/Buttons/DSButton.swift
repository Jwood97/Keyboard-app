import SwiftUI

public enum DSButtonVariant: Sendable {
  case primary
  case secondary
  case tertiary
  case ghost
  case destructive
}

public enum DSButtonSize: Sendable {
  case small
  case medium
  case large

  public var height: CGFloat {
    switch self {
      case .small:
        return 36
      case .medium:
        return 48
      case .large:
        return 56
    }
  }

  public var horizontalPadding: CGFloat {
    switch self {
      case .small:
        return DSSpacing.md
      case .medium:
        return DSSpacing.lg
      case .large:
        return DSSpacing.xl
    }
  }

  public var textStyle: DSTextStyle {
    switch self {
      case .small:
        return .footnote
      case .medium:
        return .callout
      case .large:
        return .bodyStrong
    }
  }

  public var iconSize: CGFloat {
    switch self {
      case .small:
        return 14
      case .medium:
        return 16
      case .large:
        return 18
    }
  }
}

public struct DSButton: View {
  private let title: String
  private let icon: String?
  private let trailingIcon: String?
  private let variant: DSButtonVariant
  private let size: DSButtonSize
  private let fullWidth: Bool
  private let isLoading: Bool
  private let action: () -> Void
  @Environment(\.isEnabled) private var isEnabled: Bool

  public init(
    _ title: String,
    icon: String? = nil,
    trailingIcon: String? = nil,
    variant: DSButtonVariant = .primary,
    size: DSButtonSize = .medium,
    fullWidth: Bool = false,
    isLoading: Bool = false,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.icon = icon
    self.trailingIcon = trailingIcon
    self.variant = variant
    self.size = size
    self.fullWidth = fullWidth
    self.isLoading = isLoading
    self.action = action
  }

  public var body: some View {
    Button(action: self.handleTap) {
      HStack(spacing: DSSpacing.xs) {
        if let icon = self.icon, !self.isLoading {
          Image(systemName: icon)
            .font(.system(size: self.size.iconSize, weight: .semibold))
        }
        if self.isLoading {
          ProgressView()
            .progressViewStyle(.circular)
            .controlSize(.small)
            .tint(self.foreground)
        } else {
          DSText(self.title, style: self.size.textStyle, color: self.foreground)
        }
        if let trailing = self.trailingIcon, !self.isLoading {
          Image(systemName: trailing)
            .font(.system(size: self.size.iconSize, weight: .semibold))
        }
      }
      .foregroundStyle(self.foreground)
      .frame(maxWidth: self.fullWidth ? .infinity : nil)
      .frame(height: self.size.height)
      .padding(.horizontal, self.size.horizontalPadding)
    }
    .buttonStyle(DSButtonStyle(
      variant: self.variant,
      isEnabled: self.isEnabled && !self.isLoading
    ))
    .disabled(self.isLoading)
  }

  private func handleTap() {
    DSHaptics.impact(.light)
    self.action()
  }

  private var foreground: Color {
    if !self.isEnabled { return DSColor.Text.disabled }
    switch self.variant {
      case .primary:
        return DSColor.Text.onAccent
      case .secondary:
        return DSColor.Accent.primary
      case .tertiary:
        return DSColor.Text.primary
      case .ghost:
        return DSColor.Text.primary
      case .destructive:
        return DSColor.Text.onAccent
    }
  }
}

public struct DSButtonStyle: ButtonStyle {
  let variant: DSButtonVariant
  let isEnabled: Bool

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background(
        RoundedRectangle(cornerRadius: DSRadius.pill, style: .continuous)
          .fill(self.background(pressed: configuration.isPressed))
      )
      .overlay(
        RoundedRectangle(cornerRadius: DSRadius.pill, style: .continuous)
          .strokeBorder(self.borderColor, lineWidth: self.borderWidth)
      )
      .dsShadow(self.shadow(pressed: configuration.isPressed))
      .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
      .animation(DSMotion.press, value: configuration.isPressed)
      .opacity(self.isEnabled ? 1 : 0.55)
  }

  private func background(pressed: Bool) -> Color {
    guard self.isEnabled else { return DSColor.Background.raised }
    switch self.variant {
      case .primary:
        return pressed ? DSColor.Accent.primaryPressed : DSColor.Accent.primary
      case .secondary:
        return pressed ? DSColor.Accent.primarySoft.opacity(0.7) : DSColor.Accent.primarySoft
      case .tertiary:
        return pressed ? DSColor.Background.raised : DSColor.Background.surface
      case .ghost:
        return pressed ? DSColor.Background.raised : .clear
      case .destructive:
        return pressed ? DSColor.Status.danger.opacity(0.85) : DSColor.Status.danger
    }
  }

  private var borderColor: Color {
    switch self.variant {
      case .tertiary:
        return DSColor.Border.default
      case .secondary:
        return DSColor.Accent.primary.opacity(0.25)
      default:
        return .clear
    }
  }

  private var borderWidth: CGFloat {
    switch self.variant {
      case .tertiary:
        return 1
      case .secondary:
        return 1
      default:
        return 0
    }
  }

  private func shadow(pressed: Bool) -> DSShadow {
    guard self.isEnabled else { return DSElevation.none }
    switch self.variant {
      case .primary:
        return pressed ? DSElevation.xs : DSElevation.accentGlow
      case .destructive:
        return pressed ? DSElevation.xs : DSElevation.sm
      case .tertiary:
        return DSElevation.xs
      default:
        return DSElevation.none
    }
  }
}
