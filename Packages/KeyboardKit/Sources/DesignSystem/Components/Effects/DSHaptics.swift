import UIKit

public enum DSHaptics {
  public enum Impact: Sendable {
    case soft
    case light
    case medium
    case rigid
    case heavy
  }

  public enum Notification: Sendable {
    case success
    case warning
    case error
  }

  @MainActor
  public static func impact(_ style: Impact) {
    let generator: UIImpactFeedbackGenerator
    switch style {
      case .soft:
        generator = UIImpactFeedbackGenerator(style: .soft)
      case .light:
        generator = UIImpactFeedbackGenerator(style: .light)
      case .medium:
        generator = UIImpactFeedbackGenerator(style: .medium)
      case .rigid:
        generator = UIImpactFeedbackGenerator(style: .rigid)
      case .heavy:
        generator = UIImpactFeedbackGenerator(style: .heavy)
    }
    generator.prepare()
    generator.impactOccurred()
  }

  @MainActor
  public static func notify(_ style: Notification) {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    switch style {
      case .success:
        generator.notificationOccurred(.success)
      case .warning:
        generator.notificationOccurred(.warning)
      case .error:
        generator.notificationOccurred(.error)
    }
  }

  @MainActor
  public static func selection() {
    let generator = UISelectionFeedbackGenerator()
    generator.prepare()
    generator.selectionChanged()
  }
}
