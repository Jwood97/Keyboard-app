import SwiftUI

public struct DSBanner: View {
  private let title: String
  private let message: String?
  private let icon: DSIcon?
  private let kind: DSMessageKind
  private let primaryAction: (label: String, handler: () -> Void)?
  private let secondaryAction: (label: String, handler: () -> Void)?
  private let onDismiss: (() -> Void)?

  public init(
    _ title: String,
    message: String? = nil,
    icon: DSIcon? = nil,
    kind: DSMessageKind = .info,
    primaryAction: (label: String, handler: () -> Void)? = nil,
    secondaryAction: (label: String, handler: () -> Void)? = nil,
    onDismiss: (() -> Void)? = nil
  ) {
    self.title = title
    self.message = message
    self.icon = icon
    self.kind = kind
    self.primaryAction = primaryAction
    self.secondaryAction = secondaryAction
    self.onDismiss = onDismiss
  }

  public var body: some View {
    HStack(alignment: .top, spacing: DSSpacing.md) {
      DSIconBadge(
        self.icon ?? self.defaultIcon,
        weight: .fill,
        size: .medium,
        tint: self.tint,
        surface: self.surface,
        border: self.tint.opacity(0.16)
      )
      VStack(alignment: .leading, spacing: 4) {
        HStack(alignment: .top) {
          DSText(self.title, style: .bodyStrong)
          Spacer(minLength: DSSpacing.xs)
          if let onDismiss = self.onDismiss {
            Button(action: onDismiss) {
              DSIconView(DSIcon.UI.close, weight: .regular, size: 14, tint: DSColor.Text.tertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
          }
        }
        if let message = self.message {
          DSText(message, style: .footnote, color: DSColor.Text.secondary)
        }
        if self.primaryAction != nil || self.secondaryAction != nil {
          HStack(spacing: DSSpacing.xs) {
            if let primary = self.primaryAction {
              Button(action: primary.handler) {
                DSText(primary.label, style: .captionStrong, color: self.tint)
              }
              .buttonStyle(.plain)
            }
            if let secondary = self.secondaryAction {
              Button(action: secondary.handler) {
                DSText(secondary.label, style: .captionStrong, color: DSColor.Text.secondary)
              }
              .buttonStyle(.plain)
            }
          }
          .padding(.top, 2)
        }
      }
    }
    .padding(DSSpacing.md)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
        .fill(DSColor.Background.surface)
    )
    .overlay(
      RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
        .strokeBorder(DSColor.Border.subtle, lineWidth: 1)
    )
		.overlay(alignment: .leading) {
			RoundedRectangle(cornerRadius: DSRadius.xs, style: .continuous)
				.fill(self.tint)
				.frame(width: 3)
				.padding(.vertical, 1)
				.padding(.leading, 1)
		}
    .accessibilityElement(children: .combine)
  }

  private var tint: Color {
    switch self.kind {
      case .info:
        return DSColor.Status.info
      case .success:
        return DSColor.Status.success
      case .warning:
        return DSColor.Status.warning
      case .error:
        return DSColor.Status.danger
    }
  }

  private var defaultIcon: DSIcon {
    switch self.kind {
      case .info:
        return DSIcon.Status.info
      case .success:
        return DSIcon.Status.success
      case .warning:
        return DSIcon.Status.warning
      case .error:
        return DSIcon.Status.error
    }
  }

  private var surface: Color {
    switch self.kind {
      case .info:
        return DSColor.Status.infoSurface
      case .success:
        return DSColor.Status.successSurface
      case .warning:
        return DSColor.Status.warningSurface
      case .error:
        return DSColor.Status.dangerSurface
    }
  }
}
