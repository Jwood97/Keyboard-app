import Foundation

public enum DSFieldValidationResult: Sendable, Equatable {
  case valid
  case invalid(String)
  case warning(String)

  public var isValid: Bool {
    if case .valid = self { return true }
    return false
  }

  public var state: DSFieldState {
    switch self {
      case .valid:
        return .idle
      case .invalid:
        return .error
      case .warning:
        return .warning
    }
  }

  public var message: String? {
    switch self {
      case .valid:
        return nil
      case .invalid(let text), .warning(let text):
        return text
    }
  }
}

public enum DSFieldValidationTrigger: Sendable {
  case onBlur
  case onChange
  case manual
}

public struct DSFieldValidation: Sendable {
  public let trigger: DSFieldValidationTrigger
  public let validateAllowingEmpty: Bool
  private let _validate: @Sendable (String) -> DSFieldValidationResult

  public init(
    trigger: DSFieldValidationTrigger = .onBlur,
    validateAllowingEmpty: Bool = false,
    validate: @escaping @Sendable (String) -> DSFieldValidationResult
  ) {
    self.trigger = trigger
    self.validateAllowingEmpty = validateAllowingEmpty
    self._validate = validate
  }

  public func callAsFunction(_ text: String) -> DSFieldValidationResult {
    self._validate(text)
  }

  public static func required(
    message: String = "This field is required",
    trigger: DSFieldValidationTrigger = .onBlur
  ) -> DSFieldValidation {
    DSFieldValidation(trigger: trigger, validateAllowingEmpty: true) { text in
      text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? .invalid(message)
        : .valid
    }
  }

  public static func email(
    message: String = "Enter a valid email address",
    trigger: DSFieldValidationTrigger = .onBlur
  ) -> DSFieldValidation {
    DSFieldValidation(trigger: trigger) { text in
      guard !text.isEmpty else { return .valid }
      let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
      if text.range(of: pattern, options: .regularExpression) != nil {
        return .valid
      }
      return .invalid(message)
    }
  }

  public static func minLength(
    _ count: Int,
    message: String? = nil,
    trigger: DSFieldValidationTrigger = .onBlur
  ) -> DSFieldValidation {
    let errorMessage = message ?? "Must be at least \(count) characters"
    return DSFieldValidation(trigger: trigger) { text in
      guard !text.isEmpty else { return .valid }
      return text.count >= count ? .valid : .invalid(errorMessage)
    }
  }

  public static func maxLength(
    _ count: Int,
    message: String? = nil,
    trigger: DSFieldValidationTrigger = .onChange
  ) -> DSFieldValidation {
    let errorMessage = message ?? "Must be \(count) characters or fewer"
    return DSFieldValidation(trigger: trigger) { text in
      text.count <= count ? .valid : .invalid(errorMessage)
    }
  }

  public static func regex(
    _ pattern: String,
    message: String,
    trigger: DSFieldValidationTrigger = .onBlur
  ) -> DSFieldValidation {
    DSFieldValidation(trigger: trigger) { text in
      guard !text.isEmpty else { return .valid }
      if text.range(of: pattern, options: .regularExpression) != nil {
        return .valid
      }
      return .invalid(message)
    }
  }

  public static func url(
    message: String = "Enter a valid URL",
    requiresScheme: Bool = false,
    trigger: DSFieldValidationTrigger = .onBlur
  ) -> DSFieldValidation {
    DSFieldValidation(trigger: trigger) { text in
      guard !text.isEmpty else { return .valid }
      let candidate = requiresScheme ? text : (text.contains("://") ? text : "https://\(text)")
      if let url = URL(string: candidate), url.host?.contains(".") == true {
        return .valid
      }
      return .invalid(message)
    }
  }

  public static func number(
    message: String = "Enter a valid number",
    trigger: DSFieldValidationTrigger = .onBlur
  ) -> DSFieldValidation {
    DSFieldValidation(trigger: trigger) { text in
      guard !text.isEmpty else { return .valid }
      return Double(text) != nil ? .valid : .invalid(message)
    }
  }

  public static func custom(
    trigger: DSFieldValidationTrigger = .onBlur,
    validateAllowingEmpty: Bool = false,
    _ validate: @escaping @Sendable (String) -> DSFieldValidationResult
  ) -> DSFieldValidation {
    DSFieldValidation(trigger: trigger, validateAllowingEmpty: validateAllowingEmpty, validate: validate)
  }

  public static func all(
    _ validators: [DSFieldValidation],
    trigger: DSFieldValidationTrigger? = nil
  ) -> DSFieldValidation {
    let resolved = trigger ?? validators.first?.trigger ?? .onBlur
    let captured = validators
    return DSFieldValidation(trigger: resolved, validateAllowingEmpty: true) { text in
      for validator in captured {
        if !validator.validateAllowingEmpty && text.isEmpty { continue }
        let result = validator(text)
        if !result.isValid { return result }
      }
      return .valid
    }
  }
}
