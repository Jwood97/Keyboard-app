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
      Image(systemName: self.iconName)
        .font(.system(size: 18, weight: .semibold))
        .foregroundStyle(self.tint)
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
          Image(systemName: "xmark")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(DSColor.Text.tertiary)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(DSSpacing.md)
    .background(
      RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
        .fill(self.surface)
    )
    .overlay(
      RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
        .strokeBorder(self.tint.opacity(0.25), lineWidth: 1)
    )
  }

  private var iconName: String {
    switch self.kind {
      case .info:
        return "info.circle.fill"
      case .success:
        return "checkmark.seal.fill"
      case .warning:
        return "exclamationmark.triangle.fill"
      case .error:
        return "xmark.octagon.fill"
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
