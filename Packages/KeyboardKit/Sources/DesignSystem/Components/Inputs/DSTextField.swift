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
  private let leadingIcon: String?
  private let trailingIcon: String?
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
    leadingIcon: String? = nil,
    trailingIcon: String? = nil,
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
          Image(systemName: leading)
            .foregroundStyle(DSColor.Text.tertiary)
            .font(.system(size: 16, weight: .medium))
        }
        self.field
        if self.isSecure {
          Button {
            self.isRevealed.toggle()
          } label: {
            Image(systemName: self.isRevealed ? "eye.slash" : "eye")
              .foregroundStyle(DSColor.Text.tertiary)
              .font(.system(size: 16, weight: .medium))
          }
          .buttonStyle(.plain)
        } else if let trailing = self.trailingIcon {
          Image(systemName: trailing)
            .foregroundStyle(self.accentForState)
            .font(.system(size: 16, weight: .medium))
        } else if self.state != .idle {
          Image(systemName: self.stateIcon)
            .foregroundStyle(self.accentForState)
            .font(.system(size: 16, weight: .medium))
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

  private var stateIcon: String {
    switch self.state {
      case .idle:
        return ""
      case .success:
        return "checkmark.circle.fill"
      case .warning:
        return "exclamationmark.triangle.fill"
      case .error:
        return "xmark.octagon.fill"
    }
  }
}
