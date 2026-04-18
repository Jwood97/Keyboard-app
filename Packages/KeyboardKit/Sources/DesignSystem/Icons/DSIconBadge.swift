import SwiftUI

public enum DSIconBadgeStyle: Sendable {
  case neutral
  case accent
  case success
  case warning
  case danger
  case info
}

public enum DSIconBadgeSize: Sendable {
  case small
  case medium
  case large
  case extraLarge

  fileprivate var container: CGFloat {
    switch self {
      case .small:
        return 32
      case .medium:
        return 40
      case .large:
        return 52
      case .extraLarge:
        return 68
    }
  }

  fileprivate var icon: CGFloat {
    switch self {
      case .small:
        return 14
      case .medium:
        return 18
      case .large:
        return 22
      case .extraLarge:
        return 28
    }
  }

  fileprivate var radius: CGFloat {
    switch self {
      case .small:
        return DSRadius.sm + 2
      case .medium:
        return DSRadius.md
      case .large:
        return DSRadius.lg
      case .extraLarge:
        return DSRadius.xl
    }
  }
}

public struct DSIconBadge: View {
  private let icon: DSIcon
  private let weight: DSIconWeight
  private let style: DSIconBadgeStyle
  private let size: DSIconBadgeSize
  private let circular: Bool
  private let tintOverride: Color?
  private let surfaceOverride: Color?
  private let borderOverride: Color?

  public init(
    _ icon: DSIcon,
    weight: DSIconWeight = .regular,
    style: DSIconBadgeStyle = .neutral,
    size: DSIconBadgeSize = .medium,
    circular: Bool = false,
    tint: Color? = nil,
    surface: Color? = nil,
    border: Color? = nil
  ) {
    self.icon = icon
    self.weight = weight
    self.style = style
    self.size = size
    self.circular = circular
    self.tintOverride = tint
    self.surfaceOverride = surface
    self.borderOverride = border
  }

  public var body: some View {
    RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
      .fill(self.resolvedSurface)
      .overlay(
        RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
          .strokeBorder(self.resolvedBorder, lineWidth: 1)
      )
      .overlay {
        DSIconView(self.icon, weight: self.weight, size: self.size.icon, tint: self.resolvedTint)
      }
      .frame(width: self.size.container, height: self.size.container)
  }

  private var cornerRadius: CGFloat {
    self.circular ? self.size.container / 2 : self.size.radius
  }

  private var resolvedTint: Color {
    if let tint = self.tintOverride {
      return tint
    }

    switch self.style {
      case .neutral:
        return DSColor.Text.secondary
      case .accent:
        return DSColor.Accent.primary
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

  private var resolvedSurface: Color {
    if let surface = self.surfaceOverride {
      return surface
    }
    if self.tintOverride != nil {
      return self.resolvedTint.opacity(0.11)
    }

    switch self.style {
      case .neutral:
        return DSColor.Background.muted
      case .accent:
        return DSColor.Accent.primarySoft.opacity(0.72)
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

  private var resolvedBorder: Color {
    if let border = self.borderOverride {
      return border
    }
    if self.tintOverride != nil {
      return self.resolvedTint.opacity(0.16)
    }

    switch self.style {
      case .neutral:
        return DSColor.Border.subtle
      case .accent:
        return DSColor.Accent.primary.opacity(0.16)
      case .success:
        return DSColor.Status.success.opacity(0.16)
      case .warning:
        return DSColor.Status.warning.opacity(0.18)
      case .danger:
        return DSColor.Status.danger.opacity(0.18)
      case .info:
        return DSColor.Status.info.opacity(0.18)
    }
  }
}
