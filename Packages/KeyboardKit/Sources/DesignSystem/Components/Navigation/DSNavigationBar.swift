import SwiftUI

public struct DSNavigationBar<Leading: View, Trailing: View>: View {
  private let title: String
  private let subtitle: String?
  private let leading: Leading
  private let trailing: Trailing
  private let largeTitle: Bool

  public init(
    title: String,
    subtitle: String? = nil,
    largeTitle: Bool = false,
    @ViewBuilder leading: () -> Leading = { EmptyView() },
    @ViewBuilder trailing: () -> Trailing = { EmptyView() }
  ) {
    self.title = title
    self.subtitle = subtitle
    self.largeTitle = largeTitle
    self.leading = leading()
    self.trailing = trailing()
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: self.largeTitle ? DSSpacing.md : 0) {
      HStack(spacing: DSSpacing.sm) {
        self.leading
        Spacer(minLength: DSSpacing.xs)
        self.trailing
      }
      .frame(height: 44)
      if self.largeTitle {
        VStack(alignment: .leading, spacing: 4) {
          DSText(self.title, style: .displayLarge)
          if let subtitle = self.subtitle {
            DSText(subtitle, style: .body, color: DSColor.Text.secondary)
          }
        }
      } else {
        VStack(alignment: .center, spacing: 0) {
          DSText(self.title, style: .headline, alignment: .center)
            .frame(maxWidth: .infinity)
          if let subtitle = self.subtitle {
            DSText(subtitle, style: .caption, color: DSColor.Text.tertiary, alignment: .center)
              .frame(maxWidth: .infinity)
          }
        }
        .allowsHitTesting(false)
        .offset(y: -44)
        .frame(height: 0)
      }
    }
    .padding(.horizontal, DSSpacing.md)
    .padding(.bottom, self.largeTitle ? DSSpacing.md : DSSpacing.xs)
  }
}

public struct DSBackButton: View {
  private let action: () -> Void

  public init(action: @escaping () -> Void) {
    self.action = action
  }

  public var body: some View {
    DSIconButton(icon: DSIcon.UI.chevronLeft, style: .ghost, size: .medium, tint: DSColor.Text.primary, action: self.action)
  }
}
