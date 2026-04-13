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
      withAnimation(self.isChecked ? DSMotion.checkOut : DSMotion.checkIn) {
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
              .transition(.asymmetric(
                insertion: .scale(scale: 0.3).combined(with: .opacity),
                removal: .opacity
              ))
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
}

struct DSPressScaleStyle: ButtonStyle {
  var pressedScale: CGFloat = 0.97
  var pressedOpacity: Double = 1.0

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? self.pressedScale : 1.0)
      .opacity(configuration.isPressed ? self.pressedOpacity : 1.0)
      .animation(DSMotion.press, value: configuration.isPressed)
  }
}
