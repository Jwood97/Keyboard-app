import SwiftUI

public enum DSPageControlStyle: Sendable {
  case dots
  case bars
  case numeric
}

public struct DSPageControl: View {
  private let total: Int
  private let current: Int
  private let style: DSPageControlStyle
  private let tint: Color

  public init(
    total: Int,
    current: Int,
    style: DSPageControlStyle = .dots,
    tint: Color = DSColor.Accent.primary
  ) {
    self.total = total
    self.current = current
    self.style = style
    self.tint = tint
  }

  public var body: some View {
    Group {
      switch self.style {
        case .dots:
          self.dotStyle
        case .bars:
          self.barStyle
        case .numeric:
          self.numericStyle
      }
    }
    .dsAnimation(DSMotion.snappy, value: self.current)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Page \(self.current + 1) of \(self.total)")
  }

  private var dotStyle: some View {
    HStack(spacing: 6) {
      ForEach(0..<self.total, id: \.self) { index in
        Circle()
          .fill(index == self.current ? self.tint : DSColor.Border.default)
          .frame(
            width: index == self.current ? 10 : 6,
            height: index == self.current ? 10 : 6
          )
      }
    }
  }

  private var barStyle: some View {
    HStack(spacing: 6) {
      ForEach(0..<self.total, id: \.self) { index in
        Capsule()
          .fill(index == self.current ? self.tint : DSColor.Border.default)
          .frame(
            width: index == self.current ? 22 : 10,
            height: 4
          )
      }
    }
  }

  private var numericStyle: some View {
    HStack(spacing: 4) {
      DSText("\(self.current + 1)", style: .captionStrong, color: self.tint)
      DSText("/", style: .caption, color: DSColor.Text.tertiary)
      DSText("\(self.total)", style: .caption, color: DSColor.Text.tertiary)
    }
    .padding(.horizontal, DSSpacing.sm)
    .padding(.vertical, 4)
    .background(
      Capsule()
        .fill(DSColor.Background.raised)
    )
  }
}
