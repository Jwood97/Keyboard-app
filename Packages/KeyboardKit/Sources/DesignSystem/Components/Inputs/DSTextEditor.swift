import SwiftUI

public struct DSTextEditor: View {
  private let title: String?
  private let placeholder: String
  private let minHeight: CGFloat
  private let maxLength: Int?
  @Binding private var text: String
  @FocusState private var isFocused: Bool

  public init(
    _ placeholder: String,
    text: Binding<String>,
    title: String? = nil,
    minHeight: CGFloat = 120,
    maxLength: Int? = nil
  ) {
    self.placeholder = placeholder
    self._text = text
    self.title = title
    self.minHeight = minHeight
    self.maxLength = maxLength
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.xs) {
      if let title = self.title {
        DSText(title, style: .captionStrong, color: DSColor.Text.secondary)
      }
      ZStack(alignment: .topLeading) {
        if self.text.isEmpty {
          DSText(self.placeholder, style: .body, color: DSColor.Text.placeholder)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm + 2)
        }
        TextEditor(text: self.$text)
          .focused(self.$isFocused)
          .font(DSTypography.body.font)
          .foregroundStyle(DSColor.Text.primary)
          .scrollContentBackground(.hidden)
          .padding(.horizontal, DSSpacing.sm)
          .padding(.vertical, DSSpacing.xs)
      }
      .frame(minHeight: self.minHeight, alignment: .topLeading)
      .background(
        RoundedRectangle(cornerRadius: DSRadius.field, style: .continuous)
          .fill(DSColor.Background.surface)
      )
      .overlay(
        RoundedRectangle(cornerRadius: DSRadius.field, style: .continuous)
          .strokeBorder(self.isFocused ? DSColor.Border.focus : DSColor.Border.default, lineWidth: self.isFocused ? 2 : 1)
      )
      .animation(DSMotion.quick, value: self.isFocused)
      if let maxLength = self.maxLength {
        HStack {
          Spacer()
          DSText("\(self.text.count) / \(maxLength)", style: .caption, color: DSColor.Text.tertiary)
        }
      }
    }
    .onChange(of: self.text) { _, newValue in
      if let maxLength = self.maxLength, newValue.count > maxLength {
        self.text = String(newValue.prefix(maxLength))
      }
    }
  }
}
