import SwiftUI

public enum DSBadgeStyle: Sendable {
  case accent
  case neutral
  case success
  case warning
  case danger
  case info
}

public struct DSBadge: View {
  private let text: String
  private let style: DSBadgeStyle
  private let filled: Bool

  public init(_ text: String, style: DSBadgeStyle = .neutral, filled: Bool = false) {
    self.text = text
    self.style = style
    self.filled = filled
  }

  public var body: some View {
    DSText(self.text, style: .captionStrong, color: self.foreground)
      .padding(.horizontal, 8)
      .padding(.vertical, 3)
      .background(
        Capsule().fill(self.background)
      )
  }

  private var foreground: Color {
    if self.filled { return DSColor.Text.onAccent }
    switch self.style {
      case .accent:
        return DSColor.Accent.primary
      case .neutral:
        return DSColor.Text.secondary
      case .success:
        return DSColor.Status.success
      case .warning:
        return DSColor.Status.warning
      case .danger:
        return DSColor.Status.danger
      case .info:
        return DSColor.Status.info
    }
  }

  private var background: Color {
    if self.filled {
      switch self.style {
        case .accent:
          return DSColor.Accent.primary
        case .neutral:
          return DSColor.Text.secondary
        case .success:
          return DSColor.Status.success
        case .warning:
          return DSColor.Status.warning
        case .danger:
          return DSColor.Status.danger
        case .info:
          return DSColor.Status.info
      }
    }
    switch self.style {
      case .accent:
        return DSColor.Accent.primarySoft
      case .neutral:
        return DSColor.Background.raised
      case .success:
        return DSColor.Status.successSurface
      case .warning:
        return DSColor.Status.warningSurface
      case .danger:
        return DSColor.Status.dangerSurface
      case .info:
        return DSColor.Status.infoSurface
    }
  }
}

public struct DSDot: View {
  private let color: Color
  private let size: CGFloat

  public init(color: Color = DSColor.Accent.primary, size: CGFloat = 8) {
    self.color = color
    self.size = size
  }

  public var body: some View {
    Circle()
      .fill(self.color)
      .frame(width: self.size, height: self.size)
  }
}
