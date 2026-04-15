import SwiftUI

public enum DSLinkVariant: Sendable {
  case inline
  case standalone
}

public struct DSLink: View {
  private let title: String
  private let variant: DSLinkVariant
  private let icon: DSIcon?
  private let trailingIcon: DSIcon?
  private let url: URL?
  private let action: (() -> Void)?
  @Environment(\.isEnabled) private var isEnabled: Bool
  @Environment(\.openURL) private var openURL

  public init(
    _ title: String,
    url: URL? = nil,
    icon: DSIcon? = nil,
    trailingIcon: DSIcon? = nil,
    variant: DSLinkVariant = .inline,
    action: (() -> Void)? = nil
  ) {
    self.title = title
    self.url = url
    self.icon = icon
    self.trailingIcon = trailingIcon
    self.variant = variant
    self.action = action
  }

  public var body: some View {
    Button(action: self.handleTap) {
      HStack(spacing: DSSpacing.xxs) {
        if let icon = self.icon {
          DSIconView(icon, weight: .regular, size: 14, tint: self.tint)
        }
        DSText(self.title, style: self.textStyle, color: self.tint)
          .underline(self.variant == .inline)
        if let trailing = self.trailingIcon {
          DSIconView(trailing, weight: .regular, size: 12, tint: self.tint)
        }
      }
    }
    .buttonStyle(DSPressScaleStyle(pressedScale: 0.96, pressedOpacity: 0.7))
    .opacity(self.isEnabled ? 1 : 0.5)
    .accessibilityAddTraits(.isLink)
  }

  private var tint: Color {
    DSColor.Text.link
  }

  private var textStyle: DSTextStyle {
    switch self.variant {
      case .inline:
        return .body
      case .standalone:
        return .bodyStrong
    }
  }

  private func handleTap() {
    DSHaptics.selection()
    if let action = self.action {
      action()
    } else if let url = self.url {
      self.openURL(url)
    }
  }
}
