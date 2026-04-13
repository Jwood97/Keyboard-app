import SwiftUI

public struct DSCheckbox: View {
  private let title: String?
  @Binding private var isChecked: Bool

  public init(_ title: String? = nil, isChecked: Binding<Bool>) {
    self.title = title
    self._isChecked = isChecked
  }

  public var body: some View {
    Button {
      DSHaptics.selection()
      withAnimation(DSMotion.quick) {
        self.isChecked.toggle()
      }
    } label: {
      HStack(spacing: DSSpacing.sm) {
        ZStack {
          RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(self.isChecked ? DSColor.Accent.primary : DSColor.Background.surface)
            .frame(width: 22, height: 22)
          RoundedRectangle(cornerRadius: 6, style: .continuous)
            .strokeBorder(
              self.isChecked ? DSColor.Accent.primary : DSColor.Border.default,
              lineWidth: 1.5
            )
            .frame(width: 22, height: 22)
          if self.isChecked {
            DSIconView(DSIcon.UI.check, weight: .fill, size: 14, tint: DSColor.Text.onAccent)
          }
        }
        if let title = self.title {
          DSText(title, style: .body)
        }
      }
    }
    .buttonStyle(.plain)
  }
}
