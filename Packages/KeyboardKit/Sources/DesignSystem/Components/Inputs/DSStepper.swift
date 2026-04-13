import SwiftUI

public struct DSStepper: View {
  private let title: String?
  private let range: ClosedRange<Int>
  private let step: Int
  @Binding private var value: Int

  public init(
    _ title: String? = nil,
    value: Binding<Int>,
    in range: ClosedRange<Int> = 0...100,
    step: Int = 1
  ) {
    self.title = title
    self._value = value
    self.range = range
    self.step = step
  }

  public var body: some View {
    HStack(spacing: DSSpacing.sm) {
      if let title = self.title {
        DSText(title, style: .body)
        Spacer(minLength: DSSpacing.sm)
      }
      HStack(spacing: 0) {
        StepperButton(icon: DSIcon.UI.minus, enabled: self.value > self.range.lowerBound, action: self.decrement)
        DSText("\(self.value)", style: .bodyStrong)
          .frame(width: 40)
          .contentTransition(.numericText(value: Double(self.value)))
          .animation(DSMotion.snappy, value: self.value)
        StepperButton(icon: DSIcon.UI.plus, enabled: self.value < self.range.upperBound, action: self.increment)
      }
      .frame(height: 36)
      .background(
        Capsule()
          .fill(DSColor.Background.raised)
      )
    }
  }

  private func increment() {
    withAnimation(DSMotion.snappy) {
      self.value = min(self.range.upperBound, self.value + self.step)
    }
  }

  private func decrement() {
    withAnimation(DSMotion.snappy) {
      self.value = max(self.range.lowerBound, self.value - self.step)
    }
  }
}

private struct StepperButton: View {
  let icon: DSIcon
  let enabled: Bool
  let action: () -> Void

  var body: some View {
    Button {
      if self.enabled {
        DSHaptics.impact(.light)
        self.action()
      }
    } label: {
      DSIconView(self.icon, weight: .regular, size: 16, tint: self.enabled ? DSColor.Accent.primary : DSColor.Text.tertiary)
        .frame(width: 40, height: 36)
        .opacity(self.enabled ? 1.0 : 0.5)
    }
    .buttonStyle(DSPressScaleStyle(pressedScale: 0.85))
    .disabled(!self.enabled)
  }
}
