import SwiftUI

public struct DSSegmentedControl<Value: Hashable>: View {
  public struct Option: Identifiable {
    public let id: Value
    public let title: String
    public let icon: DSIcon?

    public init(id: Value, title: String, icon: DSIcon? = nil) {
      self.id = id
      self.title = title
      self.icon = icon
    }
  }

  private let options: [Option]
  @Binding private var selection: Value
  @Namespace private var namespace
  @Environment(\.isEnabled) private var isEnabled: Bool

  public init(options: [Option], selection: Binding<Value>) {
    self.options = options
    self._selection = selection
  }

  public var body: some View {
    HStack(spacing: 6) {
      ForEach(self.options) { option in
        Button {
          DSHaptics.selection()
          withAnimation(DSMotion.refined) {
            self.selection = option.id
          }
        } label: {
          HStack(spacing: DSSpacing.xxs) {
            if let icon = option.icon {
              DSIconView(
                icon,
                weight: .regular,
                size: 14,
                tint: self.selection == option.id ? DSColor.Text.primary : DSColor.Text.secondary
              )
            }
            DSText(
              option.title,
              style: .footnote,
              color: self.selection == option.id ? DSColor.Text.primary : DSColor.Text.secondary
            )
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .padding(.horizontal, DSSpacing.xs)
          .background {
            if self.selection == option.id {
              RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
                .fill(DSColor.Background.surface)
                .overlay(
                  RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
                    .strokeBorder(DSColor.Border.subtle, lineWidth: 1)
                )
                .dsShadow(DSElevation.xs)
                .matchedGeometryEffect(id: "segment", in: self.namespace)
            }
          }
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.title)
        .accessibilityAddTraits(self.selection == option.id ? [.isButton, .isSelected] : .isButton)
      }
    }
    .padding(4)
    .background(
      RoundedRectangle(cornerRadius: DSRadius.md + 2, style: .continuous)
        .fill(DSColor.Background.muted)
    )
    .overlay(
      RoundedRectangle(cornerRadius: DSRadius.md + 2, style: .continuous)
        .strokeBorder(DSColor.Border.subtle.opacity(0.82), lineWidth: 1)
    )
    .opacity(self.isEnabled ? 1 : 0.5)
    .disabled(!self.isEnabled)
  }
}
