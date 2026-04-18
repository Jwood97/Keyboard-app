import SwiftUI

public enum DSFieldState: Sendable, Equatable {
  case idle
  case success
  case warning
  case error
}

public struct DSTextField: View {
  private let title: String?
  private let placeholder: String
  private let leadingIcon: DSIcon?
  private let trailingIcon: DSIcon?
  private let prefix: String?
  private let suffix: String?
  private let helperText: String?
  private let externalState: DSFieldState
  private let validation: DSFieldValidation?
  private let maxLength: Int?
  private let showsCharacterCount: Bool
  private let isSecure: Bool
  private let keyboardType: UIKeyboardType
  private let autocapitalization: TextInputAutocapitalization
  private let autocorrectionDisabled: Bool
  private let textContentType: UITextContentType?
  private let submitLabel: SubmitLabel
  private let onSubmit: (() -> Void)?
  @Binding private var text: String
  @FocusState private var isFocused: Bool
  @State private var isRevealed: Bool = false
  @State private var validationResult: DSFieldValidationResult = .valid
  @State private var hasBlurred: Bool = false
  @Environment(\.isEnabled) private var isEnabled: Bool

  public init(
    _ placeholder: String,
    text: Binding<String>,
    title: String? = nil,
    leadingIcon: DSIcon? = nil,
    trailingIcon: DSIcon? = nil,
    prefix: String? = nil,
    suffix: String? = nil,
    helperText: String? = nil,
    state: DSFieldState = .idle,
    validation: DSFieldValidation? = nil,
    maxLength: Int? = nil,
    showsCharacterCount: Bool = false,
    isSecure: Bool = false,
    keyboardType: UIKeyboardType = .default,
    autocapitalization: TextInputAutocapitalization = .sentences,
    autocorrectionDisabled: Bool = false,
    textContentType: UITextContentType? = nil,
    submitLabel: SubmitLabel = .done,
    onSubmit: (() -> Void)? = nil
  ) {
    self.placeholder = placeholder
    self._text = text
    self.title = title
    self.leadingIcon = leadingIcon
    self.trailingIcon = trailingIcon
    self.prefix = prefix
    self.suffix = suffix
    self.helperText = helperText
    self.externalState = state
    self.validation = validation
    self.maxLength = maxLength
    self.showsCharacterCount = showsCharacterCount
    self.isSecure = isSecure
    self.keyboardType = keyboardType
    self.autocapitalization = autocapitalization
    self.autocorrectionDisabled = autocorrectionDisabled
    self.textContentType = textContentType
    self.submitLabel = submitLabel
    self.onSubmit = onSubmit
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.xs) {
      if let title = self.title {
        DSText(title, style: .captionStrong, color: DSColor.Text.secondary)
      }
      HStack(spacing: DSSpacing.xs) {
        if let leading = self.leadingIcon {
          DSIconView(leading, weight: .regular, size: 18, tint: DSColor.Text.tertiary)
        }
        if let prefix = self.prefix {
          DSText(prefix, style: .body, color: DSColor.Text.tertiary)
        }
        self.field
        if let suffix = self.suffix {
          DSText(suffix, style: .body, color: DSColor.Text.tertiary)
        }
        if self.isSecure {
          Button {
            self.isRevealed.toggle()
          } label: {
            DSIconView(
              self.isRevealed ? DSIcon.UI.eyeSlash : DSIcon.UI.eye,
              weight: .regular,
              size: 18,
              tint: DSColor.Text.tertiary
            )
          }
          .buttonStyle(.plain)
          .accessibilityLabel(self.isRevealed ? "Hide password" : "Show password")
        } else if let trailing = self.trailingIcon {
          DSIconView(trailing, weight: .regular, size: 18, tint: self.accentForState)
        } else if let stateIcon = self.stateIcon {
          DSIconView(stateIcon, weight: .fill, size: 18, tint: self.accentForState)
            .transition(.scale(scale: 0.5).combined(with: .opacity))
        }
      }
      .padding(.horizontal, DSSpacing.md)
      .frame(height: 52)
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
      self.helperRow
    }
    .onChange(of: self.isFocused) { _, focused in
      if !focused && self.validation != nil {
        self.hasBlurred = true
        self.runValidation()
      }
    }
    .onChange(of: self.text) { _, newValue in
      if let maxLength = self.maxLength, newValue.count > maxLength {
        self.text = String(newValue.prefix(maxLength))
      }
      self.handleTextChange()
    }
    .onAppear { self.runValidationIfImmediate() }
  }

  @ViewBuilder
  private var field: some View {
    if self.isSecure && !self.isRevealed {
      SecureField(self.placeholder, text: self.$text)
        .focused(self.$isFocused)
        .font(DSTypography.body.font)
        .foregroundStyle(DSColor.Text.primary)
        .textContentType(self.textContentType)
        .submitLabel(self.submitLabel)
        .onSubmit { self.onSubmit?() }
    } else {
      TextField(self.placeholder, text: self.$text)
        .focused(self.$isFocused)
        .font(DSTypography.body.font)
        .foregroundStyle(DSColor.Text.primary)
        .textContentType(self.textContentType)
        .keyboardType(self.keyboardType)
        .autocorrectionDisabled(self.isSecure || self.autocorrectionDisabled)
        .textInputAutocapitalization(self.isSecure ? .never : self.autocapitalization)
        .submitLabel(self.submitLabel)
        .onSubmit { self.onSubmit?() }
    }
  }

  @ViewBuilder
  private var helperRow: some View {
    let message = self.resolvedMessage
    let shouldShowCounter = self.showsCharacterCount || (self.maxLength != nil && self.showsCharacterCount)
    if message != nil || shouldShowCounter {
      HStack(spacing: DSSpacing.xs) {
        if let message = message {
          DSText(message, style: .caption, color: self.helperColor)
            .transition(.opacity.combined(with: .move(edge: .top)))
            .id(message)
        }
        Spacer(minLength: 0)
        if shouldShowCounter {
          DSText(self.counterText, style: .caption, color: self.counterColor)
        }
      }
      .animation(DSMotion.quick, value: message)
    }
  }

  private var counterText: String {
    if let maxLength = self.maxLength {
      return "\(self.text.count) / \(maxLength)"
    }
    return "\(self.text.count)"
  }

  private var counterColor: Color {
    if let maxLength = self.maxLength, self.text.count >= maxLength {
      return DSColor.Status.warning
    }
    return DSColor.Text.tertiary
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
    if self.validation != nil {
      if let message = self.validationResult.message {
        return message
      }
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

  private var accentForState: Color {
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

  private var stateIcon: DSIcon? {
    switch self.resolvedState {
      case .idle:
        return nil
      case .success:
        return DSIcon.Status.success
      case .warning:
        return DSIcon.Status.warning
      case .error:
        return DSIcon.Status.error
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
