import SwiftUI

public struct DSText: View {
  private let text: String
  private let style: DSTextStyle
  private let color: Color
  private let alignment: TextAlignment

  public init(
    _ text: String,
    style: DSTextStyle = .body,
    color: Color = DSColor.Text.primary,
    alignment: TextAlignment = .leading
  ) {
    self.text = text
    self.style = style
    self.color = color
    self.alignment = alignment
  }

  public var body: some View {
    Text(self.text)
      .font(self.style.font)
      .foregroundStyle(self.color)
      .multilineTextAlignment(self.alignment)
      .lineSpacing(self.style.lineSpacing)
      .tracking(self.style.letterSpacing)
  }
}

public struct DSLabel: View {
  private let title: String
  private let icon: String
  private let style: DSTextStyle
  private let color: Color
  private let spacing: CGFloat

  public init(
    _ title: String,
    icon: String,
    style: DSTextStyle = .callout,
    color: Color = DSColor.Text.primary,
    spacing: CGFloat = DSSpacing.xs
  ) {
    self.title = title
    self.icon = icon
    self.style = style
    self.color = color
    self.spacing = spacing
  }

  public var body: some View {
    HStack(spacing: self.spacing) {
      Image(systemName: self.icon)
        .font(self.style.font)
        .foregroundStyle(self.color)
      DSText(self.title, style: self.style, color: self.color)
    }
  }
}
