import SwiftUI

public struct DSToggle: View {
  private let title: String
  private let subtitle: String?
  private let icon: DSIcon?
  @Binding private var isOn: Bool

  public init(
    _ title: String,
    isOn: Binding<Bool>,
    subtitle: String? = nil,
    icon: DSIcon? = nil
  ) {
    self.title = title
    self._isOn = isOn
    self.subtitle = subtitle
    self.icon = icon
  }

  public var body: some View {
    HStack(spacing: DSSpacing.sm) {
      if let icon = self.icon {
        DSIconView(icon, weight: .regular, size: 18, tint: DSColor.Accent.primary)
          .frame(width: 32, height: 32)
          .background(
            RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
              .fill(DSColor.Accent.primarySoft)
          )
      }
      VStack(alignment: .leading, spacing: 2) {
        DSText(self.title, style: .bodyStrong)
        if let subtitle = self.subtitle {
          DSText(subtitle, style: .caption, color: DSColor.Text.secondary)
        }
      }
      Spacer(minLength: DSSpacing.sm)
      DSSwitch(isOn: self.$isOn)
    }
  }
}

public struct DSSwitch: View {
  @Binding private var isOn: Bool

  public init(isOn: Binding<Bool>) {
    self._isOn = isOn
  }

  public var body: some View {
    Button {
      DSHaptics.selection()
      withAnimation(DSMotion.emphasised) {
        self.isOn.toggle()
      }
    } label: {
      ZStack(alignment: self.isOn ? .trailing : .leading) {
        Capsule()
          .fill(self.isOn ? DSColor.Accent.primary : DSColor.Background.raised)
          .frame(width: 52, height: 32)
          .overlay(
            Capsule()
              .strokeBorder(self.isOn ? Color.clear : DSColor.Border.default, lineWidth: 1)
          )
        Circle()
          .fill(DSColor.Background.surface)
          .frame(width: 26, height: 26)
          .dsShadow(DSElevation.xs)
          .padding(3)
      }
      .contentShape(Capsule())
    }
    .buttonStyle(DSPressScaleStyle(pressedScale: 0.96))
  }
}
