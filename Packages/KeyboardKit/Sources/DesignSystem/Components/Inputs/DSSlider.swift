import SwiftUI

public struct DSSlider: View {
  private let title: String?
  private let range: ClosedRange<Double>
  private let step: Double?
  private let valueFormatter: (Double) -> String
  @Binding private var value: Double
  @GestureState private var isDragging: Bool = false

  public init(
    _ title: String? = nil,
    value: Binding<Double>,
    in range: ClosedRange<Double> = 0...1,
    step: Double? = nil,
    valueFormatter: @escaping (Double) -> String = { String(format: "%.0f%%", $0 * 100) }
  ) {
    self.title = title
    self._value = value
    self.range = range
    self.step = step
    self.valueFormatter = valueFormatter
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.xs) {
      if let title = self.title {
        HStack {
          DSText(title, style: .captionStrong, color: DSColor.Text.secondary)
          Spacer()
          DSText(self.valueFormatter(self.value), style: .captionStrong, color: DSColor.Accent.primary)
        }
      }
      GeometryReader { proxy in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(DSColor.Background.raised)
            .frame(height: 6)
          Capsule()
            .fill(DSColor.Accent.primary)
            .frame(width: self.fillWidth(in: proxy.size.width), height: 6)
          Circle()
            .fill(DSColor.Background.surface)
            .frame(width: self.isDragging ? 28 : 22, height: self.isDragging ? 28 : 22)
            .overlay(
              Circle()
                .strokeBorder(DSColor.Accent.primary, lineWidth: 2)
            )
            .dsShadow(DSElevation.sm)
            .offset(x: self.fillWidth(in: proxy.size.width) - (self.isDragging ? 14 : 11))
            .animation(DSMotion.snappy, value: self.isDragging)
        }
        .frame(height: 28)
        .contentShape(Rectangle())
        .gesture(
          DragGesture(minimumDistance: 0)
            .updating(self.$isDragging) { _, state, _ in state = true }
            .onChanged { drag in
              self.updateValue(location: drag.location.x, width: proxy.size.width)
            }
            .onEnded { _ in
              DSHaptics.impact(.light)
            }
        )
      }
      .frame(height: 28)
    }
  }

  private func fillWidth(in total: CGFloat) -> CGFloat {
    let fraction = (self.value - self.range.lowerBound) / (self.range.upperBound - self.range.lowerBound)
    return max(0, min(1, fraction)) * total
  }

  private func updateValue(location: CGFloat, width: CGFloat) {
    let fraction = max(0, min(1, location / width))
    var newValue = self.range.lowerBound + Double(fraction) * (self.range.upperBound - self.range.lowerBound)
    if let step = self.step, step > 0 {
      newValue = (newValue / step).rounded() * step
    }
    self.value = newValue
  }
}
