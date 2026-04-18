import SwiftUI

public struct DSProgressRing: View {
  private let value: Double
  private let lineWidth: CGFloat
  private let diameter: CGFloat
  private let tint: Color
  private let showsLabel: Bool

  public init(
    value: Double,
    diameter: CGFloat = 72,
    lineWidth: CGFloat = 8,
    tint: Color = DSColor.Accent.primary,
    showsLabel: Bool = true
  ) {
    self.value = value
    self.diameter = diameter
    self.lineWidth = lineWidth
    self.tint = tint
    self.showsLabel = showsLabel
  }

  public var body: some View {
    ZStack {
      Circle()
        .stroke(DSColor.Background.raised, lineWidth: self.lineWidth)
      Circle()
        .trim(from: 0, to: max(0, min(1, self.value)))
        .stroke(self.tint, style: StrokeStyle(lineWidth: self.lineWidth, lineCap: .round))
        .rotationEffect(.degrees(-90))
        .animation(DSMotion.emphasised, value: self.value)
      if self.showsLabel {
        DSText(
          String(format: "%.0f%%", max(0, min(1, self.value)) * 100),
          style: .captionStrong,
          color: DSColor.Text.primary
        )
      }
    }
    .frame(width: self.diameter, height: self.diameter)
  }
}

