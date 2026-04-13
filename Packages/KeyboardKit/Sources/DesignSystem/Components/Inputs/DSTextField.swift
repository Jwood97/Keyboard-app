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
  private let helperText: String?
  private let state: DSFieldState
  private let isSecure: Bool
  private let keyboardType: UIKeyboardType
  private let textContentType: UITextContentType?
  private let submitLabel: SubmitLabel
  private let onSubmit: (() -> Void)?
  @Binding private var text: String
  @FocusState private var isFocused: Bool
  @State private var isRevealed: Bool = false

  public init(
    _ placeholder: String,
    text: Binding<String>,
    title: String? = nil,
    leadingIcon: DSIcon? = nil,
    trailingIcon: DSIcon? = nil,
    helperText: String? = nil,
    state: DSFieldState = .idle,
    isSecure: Bool = false,
    keyboardType: UIKeyboardType = .default,
    textContentType: UITextContentType? = nil,
    submitLabel: SubmitLabel = .done,
    onSubmit: (() -> Void)? = nil
  ) {
    self.placeholder = placeholder
    self._text = text
    self.title = title
    self.leadingIcon = leadingIcon
    self.trailingIcon = trailingIcon
    self.helperText = helperText
    self.state = state
    self.isSecure = isSecure
    self.keyboardType = keyboardType
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
        self.field
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
        } else if let trailing = self.trailingIcon {
          DSIconView(trailing, weight: .regular, size: 18, tint: self.accentForState)
        } else if let stateIcon = self.stateIcon {
          DSIconView(stateIcon, weight: .fill, size: 18, tint: self.accentForState)
        }
      }
      .padding(.horizontal, DSSpacing.md)
      .frame(height: 52)
      .background(
        RoundedRectangle(cornerRadius: DSRadius.field, style: .continuous)
          .fill(DSColor.Background.surface)
      )
      .overlay(
        RoundedRectangle(cornerRadius: DSRadius.field, style: .continuous)
          .strokeBorder(self.borderColor, lineWidth: self.isFocused ? 2 : 1)
      )
      .animation(DSMotion.quick, value: self.isFocused)
      .animation(DSMotion.quick, value: self.state)
      if let helper = self.helperText {
        DSText(helper, style: .caption, color: self.helperColor)
      }
    }
  }

  @ViewBuilder
  private var field: some View {
    if self.isSecure && !self.isRevealed {
      SecureField(self.placeholder, text: self.$text)
        .focused(self.$isFocused)
        .font(DSTypography.body)
        .foregroundStyle(DSColor.Text.primary)
        .textContentType(self.textContentType)
        .submitLabel(self.submitLabel)
        .onSubmit { self.onSubmit?() }
    } else {
      TextField(self.placeholder, text: self.$text)
        .focused(self.$isFocused)
        .font(DSTypography.body)
        .foregroundStyle(DSColor.Text.primary)
        .textContentType(self.textContentType)
        .keyboardType(self.keyboardType)
        .autocorrectionDisabled(self.isSecure)
        .textInputAutocapitalization(self.isSecure ? .never : .sentences)
        .submitLabel(self.submitLabel)
        .onSubmit { self.onSubmit?() }
    }
  }

  private var borderColor: Color {
    if self.isFocused { return DSColor.Border.focus }
    switch self.state {
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
    switch self.state {
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
    switch self.state {
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
    switch self.state {
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
}
