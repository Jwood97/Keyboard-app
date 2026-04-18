import SwiftUI

public struct DSTagInput: View {
  private let placeholder: String
  private let maxTags: Int?
  private let validator: ((String) -> Bool)?
  @Binding private var tags: [String]
  @State private var draft: String = ""
  @FocusState private var isFocused: Bool
  @Environment(\.isEnabled) private var isEnabled: Bool

  public init(
    _ placeholder: String = "Add tag",
    tags: Binding<[String]>,
    maxTags: Int? = nil,
    validator: ((String) -> Bool)? = nil
  ) {
    self.placeholder = placeholder
    self._tags = tags
    self.maxTags = maxTags
    self.validator = validator
  }

  public var body: some View {
    DSFlowLayout(spacing: DSSpacing.xxs, rowSpacing: DSSpacing.xxs) {
      ForEach(self.tags, id: \.self) { tag in
        DSChip(tag, icon: DSIcon.UI.close, style: .accent, size: .small) {
          withAnimation(DSMotion.quick) {
            self.tags.removeAll { $0 == tag }
          }
        }
      }
      if self.canAddMore {
        TextField(self.placeholder, text: self.$draft)
          .focused(self.$isFocused)
          .font(DSTypography.footnote.font)
          .foregroundStyle(DSColor.Text.primary)
          .autocorrectionDisabled(true)
          .textInputAutocapitalization(.never)
          .onSubmit { self.commit() }
          .frame(minWidth: 80)
          .padding(.horizontal, 4)
      }
    }
    .padding(DSSpacing.xs)
    .frame(minHeight: 44)
    .background(
      RoundedRectangle(cornerRadius: DSRadius.field, style: .continuous)
        .fill(DSColor.Background.surface)
    )
    .overlay(
      RoundedRectangle(cornerRadius: DSRadius.field, style: .continuous)
        .strokeBorder(
          self.isFocused ? DSColor.Border.focus : DSColor.Border.subtle,
          lineWidth: self.isFocused ? 2 : 1
        )
    )
    .contentShape(Rectangle())
    .onTapGesture {
      self.isFocused = true
    }
    .opacity(self.isEnabled ? 1 : 0.5)
    .disabled(!self.isEnabled)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Tags")
    .accessibilityValue(self.tags.joined(separator: ", "))
  }

  private var canAddMore: Bool {
    guard let max = self.maxTags else { return true }
    return self.tags.count < max
  }

  private func commit() {
    let trimmed = self.draft.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, !self.tags.contains(trimmed) else {
      self.draft = ""
      return
    }
    if let validator = self.validator, !validator(trimmed) {
      return
    }
    withAnimation(DSMotion.snappy) {
      self.tags.append(trimmed)
      self.draft = ""
    }
    DSHaptics.impact(.light)
  }
}
