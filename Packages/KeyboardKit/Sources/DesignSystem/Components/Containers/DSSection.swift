import SwiftUI

public struct DSSection<Content: View>: View {
  private let title: String?
  private let subtitle: String?
  private let footer: String?
  private let content: Content

  public init(
    _ title: String? = nil,
    subtitle: String? = nil,
    footer: String? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.subtitle = subtitle
    self.footer = footer
    self.content = content()
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      if self.title != nil || self.subtitle != nil {
        VStack(alignment: .leading, spacing: 2) {
          if let title = self.title {
            DSText(title, style: .overline, color: DSColor.Text.secondary)
          }
          if let subtitle = self.subtitle {
            DSText(subtitle, style: .caption, color: DSColor.Text.tertiary)
          }
        }
        .padding(.horizontal, DSSpacing.md)
      }
      VStack(spacing: 0) {
        self.content
      }
      .background(
        RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
          .fill(DSColor.Background.surface)
      )
      .overlay(
        RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
          .strokeBorder(DSColor.Border.subtle, lineWidth: 1)
      )
      if let footer = self.footer {
        DSText(footer, style: .caption, color: DSColor.Text.tertiary)
          .padding(.horizontal, DSSpacing.md)
      }
    }
  }
}

public struct DSDivider: View {
  private let insets: EdgeInsets
  public init(insets: EdgeInsets = EdgeInsets(top: 0, leading: DSSpacing.md, bottom: 0, trailing: DSSpacing.md)) {
    self.insets = insets
  }

  public var body: some View {
    Rectangle()
      .fill(DSColor.Border.subtle)
      .frame(height: 1)
      .padding(self.insets)
  }
}
