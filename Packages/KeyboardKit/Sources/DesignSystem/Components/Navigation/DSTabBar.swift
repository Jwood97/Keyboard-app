import SwiftUI

public struct DSTabBarItem<Value: Hashable>: Identifiable {
  public let id: Value
  public let title: String
  public let icon: DSIcon
  public let badge: String?

  public init(id: Value, title: String, icon: DSIcon, badge: String? = nil) {
    self.id = id
    self.title = title
    self.icon = icon
    self.badge = badge
  }
}

public struct DSTabBar<Value: Hashable>: View {
  private let items: [DSTabBarItem<Value>]
  @Binding private var selection: Value

  public init(items: [DSTabBarItem<Value>], selection: Binding<Value>) {
    self.items = items
    self._selection = selection
  }

  public var body: some View {
    HStack(spacing: 0) {
      ForEach(Array(self.items.enumerated()), id: \.element.id) { index, item in
        Button {
          DSHaptics.selection()
          withAnimation(DSMotion.refined) {
            self.selection = item.id
          }
        } label: {
          VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
              DSIconView(
                item.icon,
                weight: self.isSelected(item) ? .fill : .regular,
                size: 24,
                tint: self.isSelected(item) ? DSColor.Accent.primary : DSColor.Text.tertiary
              )
              .padding(8)
              .scaleEffect(self.isSelected(item) ? 1.08 : 1.0)
              .animation(DSMotion.bouncy, value: self.isSelected(item))
              if let badge = item.badge {
                DSBadge(badge, style: .danger, filled: true)
                  .offset(x: 6, y: -4)
              }
            }
            DSText(
              item.title,
              style: .caption,
              color: self.isSelected(item) ? DSColor.Accent.primary : DSColor.Text.tertiary
            )
          }
          .frame(maxWidth: .infinity)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(self.accessibilityLabel(for: item))
        .accessibilityValue("Tab \(index + 1) of \(self.items.count)")
        .accessibilityAddTraits(self.isSelected(item) ? [.isButton, .isSelected] : .isButton)
      }
    }
    .padding(.horizontal, DSSpacing.sm)
    .padding(.top, DSSpacing.xs)
    .padding(.bottom, DSSpacing.md)
    .background(
      DSColor.Background.surface
        .overlay(
          Rectangle()
            .fill(DSColor.Border.subtle)
            .frame(height: 1),
          alignment: .top
        )
        .ignoresSafeArea(edges: .bottom)
    )
  }

  private func isSelected(_ item: DSTabBarItem<Value>) -> Bool {
    self.selection == item.id
  }

  private func accessibilityLabel(for item: DSTabBarItem<Value>) -> String {
    if let badge = item.badge {
      return "\(item.title), \(badge) new"
    }
    return item.title
  }
}
