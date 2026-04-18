import SwiftUI

public enum DSMessageKind: Sendable {
  case info
  case success
  case warning
  case error
}

public struct DSInlineMessage: View {
  private let title: String
  private let description: String?
  private let kind: DSMessageKind
  private let primaryAction: (label: String, handler: () -> Void)?
  private let onDismiss: (() -> Void)?

  public init(
    _ title: String,
    description: String? = nil,
    kind: DSMessageKind = .info,
    primaryAction: (label: String, handler: () -> Void)? = nil,
    onDismiss: (() -> Void)? = nil
  ) {
    self.title = title
    self.description = description
    self.kind = kind
    self.primaryAction = primaryAction
    self.onDismiss = onDismiss
  }

  public var body: some View {
    HStack(alignment: .top, spacing: DSSpacing.sm) {
      DSIconBadge(
        self.icon,
        weight: .fill,
        size: .small,
        tint: self.tint,
        surface: self.tint.opacity(0.11),
        border: self.tint.opacity(0.16)
      )
      VStack(alignment: .leading, spacing: 4) {
        DSText(self.title, style: .bodyStrong)
        if let description = self.description {
          DSText(description, style: .footnote, color: DSColor.Text.secondary)
        }
        if let action = self.primaryAction {
          Button {
            action.handler()
          } label: {
            DSText(action.label, style: .captionStrong, color: self.tint)
          }
          .buttonStyle(.plain)
          .padding(.top, 2)
        }
      }
      Spacer(minLength: DSSpacing.xs)
      if let onDismiss = self.onDismiss {
        Button(action: onDismiss) {
          DSIconView(DSIcon.UI.close, weight: .regular, size: 14, tint: DSColor.Text.tertiary)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(DSSpacing.md)
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
  }

  private var icon: DSIcon {
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
}
