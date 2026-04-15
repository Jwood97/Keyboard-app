import SwiftUI

public enum DSChipStyle: Sendable {
  case neutral
  case soft
  case accent
  case success
  case warning
  case danger
  case info
}

public enum DSChipSize: Sendable {
  case small
  case medium
}

public struct DSChip: View {
  private let title: String
  private let icon: DSIcon?
  private let style: DSChipStyle
  private let size: DSChipSize
  private let isSelected: Bool
  private let onTap: (() -> Void)?
  @Environment(\.isEnabled) private var isEnabled: Bool

  public init(
    _ title: String,
    icon: DSIcon? = nil,
    style: DSChipStyle = .neutral,
    size: DSChipSize = .medium,
    isSelected: Bool = false,
    onTap: (() -> Void)? = nil
  ) {
    self.title = title
    self.icon = icon
    self.style = style
    self.size = size
    self.isSelected = isSelected
    self.onTap = onTap
  }

  public var body: some View {
    Group {
      if let onTap = self.onTap {
        Button {
          DSHaptics.selection()
          onTap()
        } label: {
          self.content
        }
        .buttonStyle(DSChipPressStyle())
        .accessibilityLabel(self.title)
        .accessibilityAddTraits(self.isSelected ? [.isButton, .isSelected] : .isButton)
      } else {
        self.content
      }
    }
    .opacity(self.isEnabled ? 1 : 0.5)
  }

  private var content: some View {
    HStack(spacing: DSSpacing.xxs) {
      if let icon = self.icon {
        DSIconView(icon, weight: .regular, size: self.iconSize, tint: self.foreground)
      }
      DSText(self.title, style: self.textStyle, color: self.foreground)
    }
    .padding(.horizontal, self.horizontalPadding)
    .padding(.vertical, self.verticalPadding)
    .foregroundStyle(self.foreground)
    .background(
      Capsule()
        .fill(self.background)
    )
    .overlay(
      Capsule()
        .stroke(self.borderColor, lineWidth: self.borderWidth)
    )
  }

  private var background: Color {
    switch self.style {
      case .neutral:
        return DSColor.Background.raised
      case .soft:
        return DSColor.Background.surface
      case .accent:
        return DSColor.Accent.primarySoft
      case .success:
        return DSColor.Status.successSurface
      case .warning:
        return DSColor.Status.warningSurface
      case .danger:
        return DSColor.Status.dangerSurface
      case .info:
        return DSColor.Status.infoSurface
    }
  }

  private var foreground: Color {
    switch self.style {
      case .neutral:
        return DSColor.Text.secondary
      case .soft:
        return DSColor.Text.tertiary
      case .accent:
        return DSColor.Accent.primary
      case .success:
        return DSColor.Status.success
      case .warning:
        return DSColor.Status.warning
      case .danger:
        return DSColor.Status.danger
      case .info:
        return DSColor.Status.info
    }
  }

  private var borderColor: Color {
    switch self.style {
      case .neutral:
        return DSColor.Border.subtle
      case .soft, .accent, .success, .warning, .danger, .info:
        return .clear
    }
  }

  private var borderWidth: CGFloat {
    switch self.style {
      case .neutral:
        return 1
      case .soft, .accent, .success, .warning, .danger, .info:
        return 0
    }
  }

  private var horizontalPadding: CGFloat {
    switch self.size {
      case .small:
        return DSSpacing.xs
      case .medium:
        return DSSpacing.sm
    }
  }

  private var verticalPadding: CGFloat {
    switch self.size {
      case .small:
        return 4
      case .medium:
        return 6
    }
  }

  private var iconSize: CGFloat {
    switch self.size {
      case .small:
        return 11
      case .medium:
        return 13
    }
  }

  private var textStyle: DSTextStyle {
    switch self.size {
      case .small:
        return .caption
      case .medium:
        return .footnote
    }
  }
}

private struct DSChipPressStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .opacity(configuration.isPressed ? 0.85 : 1.0)
      .animation(DSMotion.press, value: configuration.isPressed)
  }
}
