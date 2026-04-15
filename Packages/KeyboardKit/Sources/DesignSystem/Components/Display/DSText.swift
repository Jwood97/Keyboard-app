import SwiftUI

public struct DSText: View {
  private let text: String
  private let style: DSTextStyle
  private let color: Color
  private let alignment: TextAlignment
  private let scales: Bool
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @ScaledMetric private var scale: CGFloat = 1

  public init(
    _ text: String,
    style: DSTextStyle = .body,
    color: Color = DSColor.Text.primary,
    alignment: TextAlignment = .leading,
    scales: Bool = true
  ) {
    self.text = text
    self.style = style
    self.color = color
    self.alignment = alignment
    self.scales = scales
  }

  public var body: some View {
    Text(self.text)
      .font(self.effectiveFont)
      .foregroundStyle(self.color)
      .multilineTextAlignment(self.alignment)
      .lineSpacing(self.effectiveLineSpacing)
      .tracking(self.style.letterSpacing)
  }

  private var effectiveFont: Font {
    guard self.scales else { return self.style.font }
    let scaledSize = self.style.spec.size * self.scale
    let base = Font.ds(self.style.spec.family, weight: self.style.spec.weight, size: scaledSize)
    return self.style.spec.smallCaps ? base.smallCaps() : base
  }

  private var effectiveLineSpacing: CGFloat {
    self.scales ? self.style.lineSpacing * self.scale : self.style.lineSpacing
  }
}

public struct DSLabel: View {
  private let title: String
  private let icon: DSIcon
  private let iconWeight: DSIconWeight
  private let style: DSTextStyle
  private let color: Color
  private let spacing: CGFloat

  public init(
    _ title: String,
    icon: DSIcon,
    iconWeight: DSIconWeight = .regular,
    style: DSTextStyle = .callout,
    color: Color = DSColor.Text.primary,
    spacing: CGFloat = DSSpacing.xs
  ) {
    self.title = title
    self.icon = icon
    self.iconWeight = iconWeight
    self.style = style
    self.color = color
    self.spacing = spacing
  }

  public var body: some View {
    HStack(spacing: self.spacing) {
      DSIconView(self.icon, weight: self.iconWeight, size: 16, tint: self.color)
      DSText(self.title, style: self.style, color: self.color)
    }
  }
}
