import SwiftUI

public struct DSTextEditor: View {
  private let title: String?
  private let placeholder: String
  private let minHeight: CGFloat
  private let maxLength: Int?
  private let showsCharacterCount: Bool
  private let helperText: String?
  private let externalState: DSFieldState
  private let validation: DSFieldValidation?
  @Binding private var text: String
  @FocusState private var isFocused: Bool
  @State private var validationResult: DSFieldValidationResult = .valid
  @State private var hasBlurred: Bool = false
  @Environment(\.isEnabled) private var isEnabled: Bool

  public init(
    _ placeholder: String,
    text: Binding<String>,
    title: String? = nil,
    minHeight: CGFloat = 120,
    maxLength: Int? = nil,
    showsCharacterCount: Bool = true,
    helperText: String? = nil,
    state: DSFieldState = .idle,
    validation: DSFieldValidation? = nil
  ) {
    self.placeholder = placeholder
    self._text = text
    self.title = title
    self.minHeight = minHeight
    self.maxLength = maxLength
    self.showsCharacterCount = showsCharacterCount
    self.helperText = helperText
    self.externalState = state
    self.validation = validation
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
          .fill(self.isEnabled ? DSColor.Background.surface : DSColor.Background.raised)
      )
      .overlay(
        RoundedRectangle(cornerRadius: DSRadius.field, style: .continuous)
          .strokeBorder(self.borderColor, lineWidth: self.isFocused ? 2 : 1)
      )
      .opacity(self.isEnabled ? 1 : 0.55)
      .animation(DSMotion.quick, value: self.isFocused)
      .animation(DSMotion.quick, value: self.resolvedState)
      self.footerRow
    }
    .onChange(of: self.text) { _, newValue in
      if let maxLength = self.maxLength, newValue.count > maxLength {
        self.text = String(newValue.prefix(maxLength))
      }
      self.handleTextChange()
    }
    .onChange(of: self.isFocused) { _, focused in
      if !focused && self.validation != nil {
        self.hasBlurred = true
        self.runValidation()
      }
    }
    .onAppear { self.runValidationIfImmediate() }
  }

  @ViewBuilder
  private var footerRow: some View {
    let message = self.resolvedMessage
    let counter = self.showsCharacterCount && self.maxLength != nil
    if message != nil || counter {
      HStack(spacing: DSSpacing.xs) {
        if let message = message {
          DSText(message, style: .caption, color: self.helperColor)
            .id(message)
        }
        Spacer(minLength: 0)
        if counter, let maxLength = self.maxLength {
          DSText(
            "\(self.text.count) / \(maxLength)",
            style: .caption,
            color: self.text.count >= maxLength ? DSColor.Status.warning : DSColor.Text.tertiary
          )
        }
      }
      .animation(DSMotion.quick, value: message)
    }
  }

  private var resolvedState: DSFieldState {
    if self.validation != nil {
      switch self.validationResult {
        case .valid:
          return self.externalState
        case .invalid:
          return .error
        case .warning:
          return .warning
      }
    }
    return self.externalState
  }

  private var resolvedMessage: String? {
    if self.validation != nil, let message = self.validationResult.message {
      return message
    }
    return self.helperText
  }

  private var borderColor: Color {
    if self.isFocused { return DSColor.Border.focus }
    switch self.resolvedState {
      case .idle:
        return DSColor.Border.default
      case .success:
        return DSColor.Status.success
      case .warning:
        return DSColor.Status.warning
      case .error:
        return DSColor.Status.danger
    }
  }

  private var helperColor: Color {
    switch self.resolvedState {
      case .idle:
        return DSColor.Text.tertiary
      case .success:
        return DSColor.Status.success
      case .warning:
        return DSColor.Status.warning
      case .error:
        return DSColor.Status.danger
    }
  }

  private func handleTextChange() {
    guard let validation = self.validation else { return }
    switch validation.trigger {
      case .onChange:
        self.runValidation()
      case .onBlur:
        if self.hasBlurred { self.runValidation() }
      case .manual:
        break
    }
  }

  private func runValidationIfImmediate() {
    if self.validation?.trigger == .onChange {
      self.runValidation()
    }
  }

  private func runValidation() {
    guard let validation = self.validation else { return }
    withAnimation(DSMotion.quick) {
      self.validationResult = validation(self.text)
    }
  }
}
