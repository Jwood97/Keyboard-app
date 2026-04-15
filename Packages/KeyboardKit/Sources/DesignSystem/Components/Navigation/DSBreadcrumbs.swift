import SwiftUI

public struct DSBreadcrumb: Identifiable, Sendable {
  public let id = UUID()
  public let title: String
  public let handler: (@Sendable () -> Void)?

  public init(_ title: String, handler: (@Sendable () -> Void)? = nil) {
    self.title = title
    self.handler = handler
  }
}

public struct DSBreadcrumbs: View {
  private let items: [DSBreadcrumb]
  private let separator: DSIcon

  public init(
    items: [DSBreadcrumb],
    separator: DSIcon = DSIcon.UI.chevronRight
  ) {
    self.items = items
    self.separator = separator
  }

  public var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: DSSpacing.xs) {
        ForEach(Array(self.items.enumerated()), id: \.element.id) { index, item in
          let isLast = index == self.items.count - 1
          if let handler = item.handler, !isLast {
            Button {
              DSHaptics.selection()
              handler()
            } label: {
              DSText(
                item.title,
                style: .footnote,
                color: DSColor.Text.secondary
              )
            }
            .buttonStyle(DSPressScaleStyle(pressedScale: 0.96, pressedOpacity: 0.7))
          } else {
            DSText(
              item.title,
              style: isLast ? .captionStrong : .footnote,
              color: isLast ? DSColor.Text.primary : DSColor.Text.secondary
            )
          }
          if !isLast {
            DSIconView(self.separator, weight: .regular, size: 10, tint: DSColor.Text.tertiary)
          }
        }
      }
      .padding(.horizontal, DSSpacing.xs)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Breadcrumbs")
    .accessibilityValue(self.items.map(\.title).joined(separator: " / "))
  }
}
