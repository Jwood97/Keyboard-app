import SwiftUI

public struct DSSegmentedControl<Value: Hashable>: View {
  public struct Option: Identifiable {
    public let id: Value
    public let title: String
    public let icon: String?

    public init(id: Value, title: String, icon: String? = nil) {
      self.id = id
      self.title = title
      self.icon = icon
    }
  }

  private let options: [Option]
  @Binding private var selection: Value
  @Namespace private var namespace

  public init(options: [Option], selection: Binding<Value>) {
    self.options = options
    self._selection = selection
  }

  public var body: some View {
    HStack(spacing: 4) {
      ForEach(self.options) { option in
        Button {
          DSHaptics.selection()
          withAnimation(DSMotion.emphasised) {
            self.selection = option.id
          }
        } label: {
          HStack(spacing: DSSpacing.xxs) {
            if let icon = option.icon {
              Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
            }
            DSText(
              option.title,
              style: .footnote,
              color: self.selection == option.id ? DSColor.Text.primary : DSColor.Text.secondary
            )
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .background {
            if self.selection == option.id {
              RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                .fill(DSColor.Background.surface)
                .dsShadow(DSElevation.xs)
                .matchedGeometryEffect(id: "segment", in: self.namespace)
            }
          }
        }
        .buttonStyle(.plain)
      }
    }
    .padding(4)
    .background(
      RoundedRectangle(cornerRadius: DSRadius.sm + 4, style: .continuous)
        .fill(DSColor.Background.raised)
    )
  }
}
