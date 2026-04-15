import SwiftUI

/// Screen-level layout container. Applies the canonical background, safe-area fill,
/// and content padding so every screen starts from the same baseline.
///
/// Choose a `ScrollBehavior` that matches how much content the screen has:
/// - `.fixed` — no scrolling; keyboard/overlay screens or short forms
/// - `.scrollable` — VStack inside ScrollView; renders all children immediately
/// - `.lazyScrollable` — LazyVStack inside ScrollView; defers rendering;
///   good for feeds up to ~100 items. For larger datasets use `DSList`.
///
/// **Usage:**
/// ```swift
/// DSLayoutSurface(.scrollable) {
///   HeroSection()
///   FeatureList()
///   CTAButton()
/// }
/// ```
public struct DSLayoutSurface<Content: View>: View {
  public enum ScrollBehavior {
    case fixed
    case scrollable
    case lazyScrollable
  }

  private let scrollBehavior: ScrollBehavior
  private let spacing: CGFloat
  private let horizontalPadding: CGFloat
  private let verticalPadding: CGFloat
  private let background: Color
  private let onRefresh: (() async -> Void)?
  private let content: Content

  public init(
    _ scrollBehavior: ScrollBehavior = .fixed,
    spacing: CGFloat = DSSpacing.md,
    horizontalPadding: CGFloat = DSSpacing.md,
    verticalPadding: CGFloat = DSSpacing.md,
    background: Color = DSColor.Background.canvas,
    onRefresh: (() async -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.scrollBehavior = scrollBehavior
    self.spacing = spacing
    self.horizontalPadding = horizontalPadding
    self.verticalPadding = verticalPadding
    self.background = background
    self.onRefresh = onRefresh
    self.content = content()
  }

  public var body: some View {
    Group {
      switch self.scrollBehavior {
        case .fixed:
          self.fixedBody
        case .scrollable:
          self.scrollableBody(lazy: false)
        case .lazyScrollable:
          self.scrollableBody(lazy: true)
      }
    }
    .background(self.background.ignoresSafeArea())
  }

  private var fixedBody: some View {
    VStack(alignment: .leading, spacing: self.spacing) {
      self.content
    }
    .padding(.horizontal, self.horizontalPadding)
    .padding(.vertical, self.verticalPadding)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }

  @ViewBuilder
  private func scrollableBody(lazy: Bool) -> some View {
    if let onRefresh = self.onRefresh {
      ScrollView {
        self.stackContent(lazy: lazy)
      }
      .scrollIndicators(.hidden)
      .refreshable { await onRefresh() }
    } else {
      ScrollView {
        self.stackContent(lazy: lazy)
      }
      .scrollIndicators(.hidden)
    }
  }

  @ViewBuilder
  private func stackContent(lazy: Bool) -> some View {
    if lazy {
      LazyVStack(alignment: .leading, spacing: self.spacing) {
        self.content
      }
      .padding(.horizontal, self.horizontalPadding)
      .padding(.vertical, self.verticalPadding)
    } else {
      VStack(alignment: .leading, spacing: self.spacing) {
        self.content
      }
      .padding(.horizontal, self.horizontalPadding)
      .padding(.vertical, self.verticalPadding)
    }
  }
}
