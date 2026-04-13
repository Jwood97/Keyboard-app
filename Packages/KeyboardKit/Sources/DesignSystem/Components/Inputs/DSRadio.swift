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
      DSHaptics.selection()
      withAnimation(DSMotion.quick) {
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
          }
        }
        if let title = self.title {
          DSText(title, style: .body)
        }
      }
    }
    .buttonStyle(.plain)
  }

  private var isSelected: Bool {
    self.selection == self.value
  }
}
