import SwiftUI

public struct DSRadio<Value: Hashable>: View {
  private let title: String?
  private let value: Value
  @Binding private var selection: Value

  public init(_ title: String? = nil, value: Value, selection: Binding<Value>) {
    self.title = title
    self.value = value
    self._selection = selection
  }

  public var body: some View {
    Button {
      if !self.isSelected {
        DSHaptics.selection()
      }
      withAnimation(DSMotion.checkIn) {
        self.selection = self.value
      }
    } label: {
      HStack(spacing: DSSpacing.sm) {
        ZStack {
          Circle()
            .strokeBorder(
              self.isSelected ? DSColor.Accent.primary : DSColor.Border.default,
              lineWidth: 1.5
            )
            .frame(width: 22, height: 22)
          if self.isSelected {
            Circle()
              .fill(DSColor.Accent.primary)
              .frame(width: 12, height: 12)
              .transition(.scale(scale: 0.2).combined(with: .opacity))
          }
        }
        if let title = self.title {
          DSText(title, style: .body)
        }
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(DSPressScaleStyle(pressedScale: 0.92))
  }

  private var isSelected: Bool {
    self.selection == self.value
  }
}
