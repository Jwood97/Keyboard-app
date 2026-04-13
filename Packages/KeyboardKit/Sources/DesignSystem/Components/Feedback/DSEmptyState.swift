import SwiftUI

public struct DSEmptyState: View {
  private let title: String
  private let message: String?
  private let icon: String
  private let primaryAction: (label: String, handler: () -> Void)?
  private let secondaryAction: (label: String, handler: () -> Void)?

  public init(
    title: String,
    message: String? = nil,
    icon: String = "leaf.fill",
    primaryAction: (label: String, handler: () -> Void)? = nil,
    secondaryAction: (label: String, handler: () -> Void)? = nil
  ) {
    self.title = title
    self.message = message
    self.icon = icon
    self.primaryAction = primaryAction
    self.secondaryAction = secondaryAction
  }

  public var body: some View {
    VStack(spacing: DSSpacing.md) {
      ZStack {
        Circle()
          .fill(DSColor.Accent.primarySoft)
          .frame(width: 88, height: 88)
        Image(systemName: self.icon)
          .font(.system(size: 34, weight: .semibold))
          .foregroundStyle(DSColor.Accent.primary)
      }
      VStack(spacing: DSSpacing.xs) {
        DSText(self.title, style: .title, alignment: .center)
        if let message = self.message {
          DSText(message, style: .body, color: DSColor.Text.secondary, alignment: .center)
            .padding(.horizontal, DSSpacing.lg)
        }
      }
      if self.primaryAction != nil || self.secondaryAction != nil {
        VStack(spacing: DSSpacing.xs) {
          if let primary = self.primaryAction {
            DSButton(primary.label, variant: .primary, size: .medium, fullWidth: true, action: primary.handler)
          }
          if let secondary = self.secondaryAction {
            DSButton(secondary.label, variant: .ghost, size: .medium, fullWidth: true, action: secondary.handler)
          }
        }
        .padding(.horizontal, DSSpacing.xl)
        .padding(.top, DSSpacing.sm)
      }
    }
    .padding(DSSpacing.lg)
    .frame(maxWidth: .infinity)
  }
}
