import SwiftUI

public enum DSListRowAccessory: Sendable {
  case none
  case chevron
  case info(String)
  case badge(String)
}

public struct DSListRow<Trailing: View>: View {
  private let title: String
  private let subtitle: String?
  private let icon: DSIcon?
  private let iconWeight: DSIconWeight
  private let iconTint: Color
  private let accessory: DSListRowAccessory
  private let destructive: Bool
  private let action: (() -> Void)?
  private let accessibilityHint: String?
  private let trailing: Trailing
  @Environment(\.isEnabled) private var isEnabled: Bool

  public init(
    _ title: String,
    subtitle: String? = nil,
    icon: DSIcon? = nil,
    iconWeight: DSIconWeight = .regular,
    iconTint: Color = DSColor.Accent.primary,
    accessory: DSListRowAccessory = .chevron,
    destructive: Bool = false,
    action: (() -> Void)? = nil,
    accessibilityHint: String? = nil,
    @ViewBuilder trailing: () -> Trailing = { EmptyView() }
  ) {
    self.title = title
    self.subtitle = subtitle
    self.icon = icon
    self.iconWeight = iconWeight
    self.iconTint = iconTint
    self.accessory = accessory
    self.destructive = destructive
    self.action = action
    self.accessibilityHint = accessibilityHint
    self.trailing = trailing()
  }

  public var body: some View {
    Group {
      if let action = self.action {
        Button {
          DSHaptics.selection()
          action()
        } label: {
          self.content
        }
        .buttonStyle(RowButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(self.combinedAccessibilityLabel)
        .accessibilityValue(self.accessoryAccessibilityValue)
        .accessibilityHint(self.accessibilityHint ?? "")
        .accessibilityAddTraits(.isButton)
        .opacity(self.isEnabled ? 1 : 0.5)
      } else {
        self.content
          .accessibilityElement(children: .combine)
          .accessibilityLabel(self.combinedAccessibilityLabel)
          .accessibilityValue(self.accessoryAccessibilityValue)
      }
    }
  }

  private var combinedAccessibilityLabel: String {
    if let subtitle = self.subtitle {
      return "\(self.title). \(subtitle)"
    }
    return self.title
  }

  private var accessoryAccessibilityValue: String {
    switch self.accessory {
      case .info(let text):
        return text
      case .badge(let text):
        return text
      case .chevron, .none:
        return ""
    }
  }

  private var content: some View {
    HStack(spacing: DSSpacing.sm) {
      if let icon = self.icon {
        DSIconView(
          icon,
          weight: self.iconWeight,
          size: 20,
          tint: self.destructive ? DSColor.Status.danger : self.iconTint
        )
        .frame(width: 36, height: 36)
        .background(
          RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
            .fill(
              self.destructive
                ? DSColor.Status.dangerSurface
                : self.iconTint.opacity(0.14)
            )
        )
      }
      VStack(alignment: .leading, spacing: 2) {
        DSText(
          self.title,
          style: .bodyStrong,
          color: self.destructive ? DSColor.Status.danger : DSColor.Text.primary
        )
        if let subtitle = self.subtitle {
          DSText(subtitle, style: .caption, color: DSColor.Text.secondary)
        }
      }
      Spacer(minLength: DSSpacing.sm)
      if Trailing.self != EmptyView.self {
        self.trailing
      } else {
        self.accessoryView
      }
    }
    .padding(.vertical, DSSpacing.sm)
    .padding(.horizontal, DSSpacing.md)
    .contentShape(Rectangle())
  }

  @ViewBuilder
  private var accessoryView: some View {
    switch self.accessory {
      case .none:
        EmptyView()
      case .chevron:
        DSIconView(DSIcon.UI.chevronRight, weight: .regular, size: 14, tint: DSColor.Text.tertiary)
      case let .info(text):
        DSText(text, style: .footnote, color: DSColor.Text.secondary)
      case let .badge(text):
        DSChip(text, style: .accent, size: .small)
    }
  }
}

private struct RowButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background(
        (configuration.isPressed ? DSColor.Background.raised : Color.clear)
          .animation(DSMotion.quick, value: configuration.isPressed)
      )
      .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
      .animation(DSMotion.press, value: configuration.isPressed)
  }
}
