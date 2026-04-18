import SwiftUI

public struct DSAlertAction: Identifiable, Sendable {
  public let id = UUID()
  public let title: String
  public let role: DSAlertRole
  public let handler: @Sendable () -> Void

  public init(
    _ title: String,
    role: DSAlertRole = .default,
    handler: @escaping @Sendable () -> Void = {}
  ) {
    self.title = title
    self.role = role
    self.handler = handler
  }

  public static func cancel(_ title: String = "Cancel", handler: @escaping @Sendable () -> Void = {}) -> DSAlertAction {
    DSAlertAction(title, role: .cancel, handler: handler)
  }

  public static func destructive(_ title: String, handler: @escaping @Sendable () -> Void) -> DSAlertAction {
    DSAlertAction(title, role: .destructive, handler: handler)
  }

  public static func primary(_ title: String, handler: @escaping @Sendable () -> Void) -> DSAlertAction {
    DSAlertAction(title, role: .primary, handler: handler)
  }
}

public enum DSAlertRole: Sendable {
  case `default`
  case primary
  case cancel
  case destructive
}

public struct DSAlert: View {
  private let title: String
  private let message: String?
  private let icon: DSIcon?
  private let kind: DSMessageKind
  private let actions: [DSAlertAction]
  @Binding private var isPresented: Bool

  public init(
    _ title: String,
    message: String? = nil,
    icon: DSIcon? = nil,
    kind: DSMessageKind = .info,
    isPresented: Binding<Bool>,
    actions: [DSAlertAction]
  ) {
    self.title = title
    self.message = message
    self.icon = icon
    self.kind = kind
    self._isPresented = isPresented
    self.actions = actions
  }

  public var body: some View {
    VStack(spacing: DSSpacing.md) {
      if let icon = self.icon ?? self.defaultIcon {
        ZStack {
          Circle()
            .fill(self.tint.opacity(DSOpacity.soft))
            .frame(width: 56, height: 56)
          DSIconView(icon, weight: .fill, size: 28, tint: self.tint)
        }
      }
      VStack(spacing: DSSpacing.xs) {
        DSText(self.title, style: .titleSmall, alignment: .center)
        if let message = self.message {
          DSText(message, style: .footnote, color: DSColor.Text.secondary, alignment: .center)
        }
      }
      VStack(spacing: DSSpacing.xs) {
        ForEach(self.actions) { action in
          DSButton(
            action.title,
            variant: self.variant(for: action.role),
            size: .medium,
            fullWidth: true,
            action: {
              action.handler()
              self.isPresented = false
            }
          )
        }
      }
    }
    .padding(DSSpacing.lg)
    .frame(maxWidth: 360)
    .background(
      RoundedRectangle(cornerRadius: DSRadius.xl, style: .continuous)
        .fill(DSColor.Background.surface)
    )
    .dsShadow(DSElevation.xl)
    .padding(DSSpacing.xl)
  }

  private var tint: Color {
    switch self.kind {
      case .info:
        return DSColor.Accent.primary
      case .success:
        return DSColor.Status.success
      case .warning:
        return DSColor.Status.warning
      case .error:
        return DSColor.Status.danger
    }
  }

  private var defaultIcon: DSIcon? {
    switch self.kind {
      case .info:
        return DSIcon.Status.info
      case .success:
        return DSIcon.Status.success
      case .warning:
        return DSIcon.Status.warning
      case .error:
        return DSIcon.Status.error
    }
  }

  private func variant(for role: DSAlertRole) -> DSButtonVariant {
    switch role {
      case .primary:
        return .primary
      case .destructive:
        return .destructive
      case .cancel:
        return .tertiary
      case .default:
        return .secondary
    }
  }
}

public extension View {
  func dsAlert(
    _ title: String,
    message: String? = nil,
    icon: DSIcon? = nil,
    kind: DSMessageKind = .info,
    isPresented: Binding<Bool>,
    actions: [DSAlertAction]
  ) -> some View {
    self.modifier(DSAlertModifier(
      title: title,
      message: message,
      icon: icon,
      kind: kind,
      isPresented: isPresented,
      actions: actions
    ))
  }
}

private struct DSAlertModifier: ViewModifier {
  let title: String
  let message: String?
  let icon: DSIcon?
  let kind: DSMessageKind
  @Binding var isPresented: Bool
  let actions: [DSAlertAction]

  func body(content: Content) -> some View {
    content.overlay {
      if self.isPresented {
        ZStack {
          DSColor.Background.overlay
            .ignoresSafeArea()
            .transition(.opacity)
            .onTapGesture {
              if let cancel = self.actions.first(where: { $0.role == .cancel }) {
                cancel.handler()
                self.isPresented = false
              }
            }
          DSAlert(
            self.title,
            message: self.message,
            icon: self.icon,
            kind: self.kind,
            isPresented: self.$isPresented,
            actions: self.actions
          )
          .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
        .zIndex(DSZIndex.modal)
      }
    }
    .dsAnimation(DSMotion.emphasised, value: self.isPresented)
  }
}
