import SwiftUI

public struct DSSearchBar: View {
  private let placeholder: String
  private let onSubmit: (() -> Void)?
  @Binding private var query: String
  @FocusState private var isFocused: Bool

  public init(
    _ placeholder: String = "Search",
    query: Binding<String>,
    onSubmit: (() -> Void)? = nil
  ) {
    self.placeholder = placeholder
    self._query = query
    self.onSubmit = onSubmit
  }

  public var body: some View {
    HStack(spacing: DSSpacing.xs) {
      DSIconView(DSIcon.UI.search, weight: .regular, size: 18, tint: DSColor.Text.tertiary)
      TextField(self.placeholder, text: self.$query)
        .focused(self.$isFocused)
        .font(DSTypography.body.font)
        .foregroundStyle(DSColor.Text.primary)
        .submitLabel(.search)
        .onSubmit { self.onSubmit?() }
      if !self.query.isEmpty {
        Button {
          self.query = ""
        } label: {
          DSIconView(DSIcon.UI.dismiss, weight: .fill, size: 18, tint: DSColor.Text.tertiary)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.horizontal, DSSpacing.sm)
    .frame(height: 44)
    .background(
      Capsule().fill(DSColor.Background.raised)
    )
    .overlay(
      Capsule().strokeBorder(
        self.isFocused ? DSColor.Border.focus : Color.clear,
        lineWidth: 2
      )
    )
    .animation(DSMotion.quick, value: self.isFocused)
  }
}
