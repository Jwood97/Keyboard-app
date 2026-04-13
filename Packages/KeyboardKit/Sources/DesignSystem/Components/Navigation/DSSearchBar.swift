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
      Image(systemName: "magnifyingglass")
        .foregroundStyle(DSColor.Text.tertiary)
        .font(.system(size: 16, weight: .medium))
      TextField(self.placeholder, text: self.$query)
        .focused(self.$isFocused)
        .font(DSTypography.body)
        .foregroundStyle(DSColor.Text.primary)
        .submitLabel(.search)
        .onSubmit { self.onSubmit?() }
      if !self.query.isEmpty {
        Button {
          self.query = ""
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(DSColor.Text.tertiary)
            .font(.system(size: 16))
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
