import SwiftUI

public struct DSDisclosure<Content: View>: View {
  private let title: String
  private let subtitle: String?
  private let icon: DSIcon?
  @Binding private var isExpanded: Bool
  private let content: Content

  public init(
    _ title: String,
    subtitle: String? = nil,
    icon: DSIcon? = nil,
    isExpanded: Binding<Bool>,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.subtitle = subtitle
    self.icon = icon
    self._isExpanded = isExpanded
    self.content = content()
  }

  public init(
    _ title: String,
    subtitle: String? = nil,
    icon: DSIcon? = nil,
    initiallyExpanded: Bool = false,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.subtitle = subtitle
    self.icon = icon
    self._isExpanded = .constant(initiallyExpanded)
    self.content = content()
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Button {
        DSHaptics.selection()
        withAnimation(DSMotion.refined) {
          self.isExpanded.toggle()
        }
      } label: {
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
          DSIconView(
            DSIcon.UI.chevronDown,
            weight: .regular,
            size: 14,
            tint: DSColor.Text.secondary
          )
          .rotationEffect(.degrees(self.isExpanded ? 180 : 0))
        }
        .padding(.vertical, DSSpacing.sm)
        .padding(.horizontal, DSSpacing.md)
        .contentShape(Rectangle())
      }
      .buttonStyle(DSPressScaleStyle(pressedScale: 0.995, pressedOpacity: 0.9))
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(self.title)
      .accessibilityValue(self.isExpanded ? "Expanded" : "Collapsed")
      .accessibilityAddTraits(.isButton)
      if self.isExpanded {
        self.content
          .padding(.horizontal, DSSpacing.md)
          .padding(.bottom, DSSpacing.md)
          .transition(.opacity.combined(with: .move(edge: .top)))
      }
    }
    .background(
      RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
        .fill(DSColor.Background.surface)
    )
    .overlay(
      RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
        .strokeBorder(DSColor.Border.subtle, lineWidth: 1)
    )
  }
}
