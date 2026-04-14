import SwiftUI

public struct DSRadio<Value: Hashable>: View {
  private let title: String?
  private let value: Value
  private let accessibilityLabel: String?
  @Binding private var selection: Value
  @Environment(\.isEnabled) private var isEnabled: Bool

  public init(
    _ title: String? = nil,
    value: Value,
    selection: Binding<Value>,
    accessibilityLabel: String? = nil
  ) {
    self.title = title
    self.value = value
    self._selection = selection
    self.accessibilityLabel = accessibilityLabel
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
      .opacity(self.isEnabled ? 1 : 0.5)
    }
    .buttonStyle(DSPressScaleStyle(pressedScale: 0.92))
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(self.accessibilityLabel ?? self.title ?? "Radio")
    .accessibilityValue(self.isSelected ? "Selected" : "Not selected")
    .accessibilityAddTraits(self.isSelected ? [.isButton, .isSelected] : .isButton)
  }

  private var isSelected: Bool {
    self.selection == self.value
  }
}
