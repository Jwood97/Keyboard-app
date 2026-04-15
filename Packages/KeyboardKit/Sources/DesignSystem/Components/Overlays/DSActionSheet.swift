import SwiftUI

public struct DSActionSheetItem: Identifiable, Sendable {
  public let id = UUID()
  public let title: String
  public let subtitle: String?
  public let icon: DSIcon?
  public let role: DSAlertRole
  public let handler: @Sendable () -> Void

  public init(
    _ title: String,
    subtitle: String? = nil,
    icon: DSIcon? = nil,
    role: DSAlertRole = .default,
    handler: @escaping @Sendable () -> Void
  ) {
    self.title = title
    self.subtitle = subtitle
    self.icon = icon
    self.role = role
    self.handler = handler
  }
}

public struct DSActionSheet: View {
  private let title: String?
  private let message: String?
  private let items: [DSActionSheetItem]
  private let cancelLabel: String
  @Binding private var isPresented: Bool

  public init(
    title: String? = nil,
    message: String? = nil,
    items: [DSActionSheetItem],
    cancelLabel: String = "Cancel",
    isPresented: Binding<Bool>
  ) {
    self.title = title
    self.message = message
    self.items = items
    self.cancelLabel = cancelLabel
    self._isPresented = isPresented
  }

  public var body: some View {
    VStack(spacing: DSSpacing.xs) {
      VStack(spacing: 0) {
        if self.title != nil || self.message != nil {
          VStack(spacing: 4) {
            if let title = self.title {
              DSText(title, style: .captionStrong, color: DSColor.Text.secondary, alignment: .center)
            }
            if let message = self.message {
              DSText(message, style: .caption, color: DSColor.Text.tertiary, alignment: .center)
            }
          }
          .frame(maxWidth: .infinity)
          .padding(DSSpacing.md)
          Divider().overlay(DSColor.Border.subtle)
        }
        ForEach(Array(self.items.enumerated()), id: \.element.id) { index, item in
          Button {
            item.handler()
            self.isPresented = false
          } label: {
            HStack(spacing: DSSpacing.sm) {
              if let icon = item.icon {
                DSIconView(icon, weight: .regular, size: 18, tint: self.tint(for: item.role))
              }
              VStack(alignment: .leading, spacing: 2) {
                DSText(item.title, style: .bodyStrong, color: self.tint(for: item.role))
                if let subtitle = item.subtitle {
                  DSText(subtitle, style: .caption, color: DSColor.Text.secondary)
                }
              }
              Spacer(minLength: 0)
            }
            .padding(DSSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
          }
          .buttonStyle(DSPressScaleStyle(pressedScale: 0.98, pressedOpacity: 0.85))
          if index < self.items.count - 1 {
            Divider().overlay(DSColor.Border.subtle)
          }
        }
      }
      .background(
        RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
          .fill(DSColor.Background.surface)
      )
      Button {
        self.isPresented = false
      } label: {
        DSText(self.cancelLabel, style: .bodyStrong, color: DSColor.Accent.primary, alignment: .center)
          .frame(maxWidth: .infinity)
          .padding(DSSpacing.md)
          .background(
            RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
              .fill(DSColor.Background.surface)
          )
      }
      .buttonStyle(DSPressScaleStyle(pressedScale: 0.98, pressedOpacity: 0.85))
    }
    .padding(.horizontal, DSSpacing.sm)
    .padding(.bottom, DSSpacing.sm)
  }

  private func tint(for role: DSAlertRole) -> Color {
    switch role {
      case .destructive:
        return DSColor.Status.danger
      case .primary:
        return DSColor.Accent.primary
      case .default, .cancel:
        return DSColor.Text.primary
    }
  }
}

public extension View {
  func dsActionSheet(
    title: String? = nil,
    message: String? = nil,
    items: [DSActionSheetItem],
    cancelLabel: String = "Cancel",
    isPresented: Binding<Bool>
  ) -> some View {
    self.modifier(DSActionSheetModifier(
      title: title,
      message: message,
      items: items,
      cancelLabel: cancelLabel,
      isPresented: isPresented
    ))
  }
}

private struct DSActionSheetModifier: ViewModifier {
  let title: String?
  let message: String?
  let items: [DSActionSheetItem]
  let cancelLabel: String
  @Binding var isPresented: Bool

  func body(content: Content) -> some View {
    content.overlay {
      if self.isPresented {
        ZStack(alignment: .bottom) {
          DSColor.Background.overlay
            .ignoresSafeArea()
            .transition(.opacity)
            .onTapGesture {
              self.isPresented = false
            }
          DSActionSheet(
            title: self.title,
            message: self.message,
            items: self.items,
            cancelLabel: self.cancelLabel,
            isPresented: self.$isPresented
          )
          .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .zIndex(DSZIndex.sheet)
      }
    }
    .dsAnimation(DSMotion.overlay, value: self.isPresented)
  }
}
