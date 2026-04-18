import SwiftUI

public enum DSProgressStyle: Sendable {
  case determinate
  case indeterminate
}

public struct DSProgressBar: View {
  private let value: Double
  private let style: DSProgressStyle
  private let tint: Color
  private let height: CGFloat
  private let label: String?
  @State private var indeterminateOffset: CGFloat = -0.3

  public init(
    value: Double = 0,
    style: DSProgressStyle = .determinate,
    tint: Color = DSColor.Accent.primary,
    height: CGFloat = 8,
    label: String? = nil
  ) {
    self.value = value
    self.style = style
    self.tint = tint
    self.height = height
    self.label = label
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.xs) {
      if let label = self.label {
        HStack {
          DSText(label, style: .captionStrong, color: DSColor.Text.secondary)
          Spacer()
          if self.style == .determinate {
            DSText(self.percentText, style: .captionStrong, color: self.tint)
          }
        }
      }
      GeometryReader { proxy in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(DSColor.Background.raised)
          switch self.style {
            case .determinate:
              Capsule()
                .fill(self.tint)
                .frame(width: max(0, min(1, self.value)) * proxy.size.width)
                .animation(DSMotion.emphasised, value: self.value)
            case .indeterminate:
              Capsule()
                .fill(self.tint)
                .frame(width: proxy.size.width * 0.4)
                .offset(x: self.indeterminateOffset * proxy.size.width)
          }
        }
      }
      .frame(height: self.height)
      .clipShape(Capsule())
    }
    .onAppear { self.startIndeterminateIfNeeded() }
  }

  private var percentText: String {
    String(format: "%.0f%%", max(0, min(1, self.value)) * 100)
  }

  private func startIndeterminateIfNeeded() {
    guard self.style == .indeterminate else { return }
    withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
      self.indeterminateOffset = 1.3
    }
  }
}
