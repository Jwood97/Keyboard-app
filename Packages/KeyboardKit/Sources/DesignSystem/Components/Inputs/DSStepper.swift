import SwiftUI

public struct DSStepper: View {
  private let title: String?
  private let range: ClosedRange<Int>
  private let step: Int
  @Binding private var value: Int
  @Environment(\.isEnabled) private var isEnabled: Bool

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
        StepperButton(
          icon: DSIcon.UI.minus,
          enabled: self.isEnabled && self.value > self.range.lowerBound,
          label: "Decrement \(self.title ?? "value")",
          action: self.decrement
        )
        DSText("\(self.value)", style: .bodyStrong)
          .frame(width: 40)
          .contentTransition(.numericText(value: Double(self.value)))
          .animation(DSMotion.snappy, value: self.value)
        StepperButton(
          icon: DSIcon.UI.plus,
          enabled: self.isEnabled && self.value < self.range.upperBound,
          label: "Increment \(self.title ?? "value")",
          action: self.increment
        )
      }
      .frame(height: 36)
      .background(
        Capsule()
          .fill(DSColor.Background.raised)
      )
      .opacity(self.isEnabled ? 1 : 0.5)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(self.title ?? "Stepper")
    .accessibilityValue("\(self.value)")
    .accessibilityAdjustableAction { direction in
      switch direction {
        case .increment:
          self.increment()
        case .decrement:
          self.decrement()
        @unknown default:
          break
      }
    }
  }

  private func increment() {
    guard self.isEnabled, self.value < self.range.upperBound else { return }
    DSHaptics.impact(.light)
    withAnimation(DSMotion.snappy) {
      self.value = min(self.range.upperBound, self.value + self.step)
    }
  }

  private func decrement() {
    guard self.isEnabled, self.value > self.range.lowerBound else { return }
    DSHaptics.impact(.light)
    withAnimation(DSMotion.snappy) {
      self.value = max(self.range.lowerBound, self.value - self.step)
    }
  }
}

private struct StepperButton: View {
  let icon: DSIcon
  let enabled: Bool
  let label: String
  let action: () -> Void

  var body: some View {
    Button {
      if self.enabled {
        self.action()
      }
    } label: {
      DSIconView(self.icon, weight: .regular, size: 16, tint: self.enabled ? DSColor.Accent.primary : DSColor.Text.tertiary)
        .frame(width: 40, height: 36)
        .opacity(self.enabled ? 1.0 : 0.5)
    }
    .buttonStyle(DSPressScaleStyle(pressedScale: 0.85))
    .disabled(!self.enabled)
    .accessibilityLabel(self.label)
    .accessibilityHidden(true)
  }
}
