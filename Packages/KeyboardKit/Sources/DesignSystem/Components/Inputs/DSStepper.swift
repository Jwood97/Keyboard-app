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
        self.button(icon: "minus", action: self.decrement)
          .disabled(self.value <= self.range.lowerBound)
        DSText("\(self.value)", style: .bodyStrong)
          .frame(width: 40)
        self.button(icon: "plus", action: self.increment)
          .disabled(self.value >= self.range.upperBound)
      }
      .frame(height: 36)
      .background(
        Capsule()
          .fill(DSColor.Background.raised)
      )
    }
  }

  private func button(icon: String, action: @escaping () -> Void) -> some View {
    Button {
      DSHaptics.impact(.light)
      action()
    } label: {
      Image(systemName: icon)
        .font(.system(size: 14, weight: .bold))
        .foregroundStyle(DSColor.Accent.primary)
        .frame(width: 40, height: 36)
    }
    .buttonStyle(.plain)
  }

  private func increment() {
    self.value = min(self.range.upperBound, self.value + self.step)
  }

  private func decrement() {
    self.value = max(self.range.lowerBound, self.value - self.step)
  }
}
