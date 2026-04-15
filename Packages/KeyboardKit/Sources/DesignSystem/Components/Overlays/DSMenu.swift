import SwiftUI

public struct DSMenuItem: Identifiable, Sendable {
  public let id = UUID()
  public let title: String
  public let icon: DSIcon?
  public let shortcut: String?
  public let role: DSAlertRole
  public let isDisabled: Bool
  public let handler: @Sendable () -> Void

  public init(
    _ title: String,
    icon: DSIcon? = nil,
    shortcut: String? = nil,
    role: DSAlertRole = .default,
    isDisabled: Bool = false,
    handler: @escaping @Sendable () -> Void
  ) {
    self.title = title
    self.icon = icon
    self.shortcut = shortcut
    self.role = role
    self.isDisabled = isDisabled
    self.handler = handler
  }
}

public struct DSMenu<Label: View>: View {
  private let items: [DSMenuItem]
  private let label: Label
  @State private var isOpen: Bool = false

  public init(
    items: [DSMenuItem],
    @ViewBuilder label: () -> Label
  ) {
    self.items = items
    self.label = label()
  }

  public var body: some View {
    Button {
      DSHaptics.selection()
      withAnimation(DSMotion.snappy) {
        self.isOpen.toggle()
      }
    } label: {
      self.label
    }
    .buttonStyle(DSPressScaleStyle(pressedScale: 0.96))
    .overlay(alignment: .topTrailing) {
      if self.isOpen {
        DSMenuSurface(items: self.items) {
          withAnimation(DSMotion.quick) {
            self.isOpen = false
          }
        }
        .offset(y: 44)
        .transition(.scale(scale: 0.9, anchor: .topTrailing).combined(with: .opacity))
        .zIndex(DSZIndex.overlay)
      }
    }
  }
}

public struct DSMenuSurface: View {
  private let items: [DSMenuItem]
  private let onDismiss: () -> Void

  public init(items: [DSMenuItem], onDismiss: @escaping () -> Void) {
    self.items = items
    self.onDismiss = onDismiss
  }

  public var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(self.items.enumerated()), id: \.element.id) { index, item in
        Button {
          guard !item.isDisabled else { return }
          item.handler()
          self.onDismiss()
        } label: {
          HStack(spacing: DSSpacing.sm) {
            if let icon = item.icon {
              DSIconView(
                icon,
                weight: .regular,
                size: 16,
                tint: self.tint(for: item.role, disabled: item.isDisabled)
              )
              .frame(width: 18)
            }
            DSText(
              item.title,
              style: .callout,
              color: self.tint(for: item.role, disabled: item.isDisabled)
            )
            Spacer(minLength: DSSpacing.md)
            if let shortcut = item.shortcut {
              DSText(shortcut, style: .caption, color: DSColor.Text.tertiary)
            }
          }
          .padding(.horizontal, DSSpacing.md)
          .padding(.vertical, DSSpacing.xs)
          .frame(maxWidth: .infinity, alignment: .leading)
          .contentShape(Rectangle())
        }
        .buttonStyle(DSPressScaleStyle(pressedScale: 0.98, pressedOpacity: 0.7))
        .disabled(item.isDisabled)
        if index < self.items.count - 1 && item.role == .destructive {
          Divider().overlay(DSColor.Border.subtle)
        }
      }
    }
    .padding(.vertical, DSSpacing.xs)
    .frame(minWidth: 200)
    .background(
      RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
        .fill(DSColor.Background.surface)
    )
    .overlay(
      RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
        .strokeBorder(DSColor.Border.subtle, lineWidth: 1)
    )
    .dsShadow(DSElevation.lg)
  }

  private func tint(for role: DSAlertRole, disabled: Bool) -> Color {
    if disabled { return DSColor.Text.disabled }
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
