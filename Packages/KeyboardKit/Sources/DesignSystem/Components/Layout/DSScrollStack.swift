import SwiftUI

/// LazyVStack inside a ScrollView. Views are instantiated lazily but not recycled —
/// memory grows with scroll position.
///
/// **When to use:**
/// - Custom card feeds with mixed content types
/// - Up to ~100 items (beyond that, prefer `DSList`)
/// - When swipe actions / reordering are not needed
///
/// **When NOT to use:**
/// - Large or unbounded datasets → use `DSList`
/// - Fewer than ~20 static items → use plain `VStack`
///
/// **Usage:**
/// ```swift
/// DSScrollStack {
///   ForEach(models) { model in
///     ModelCard(model)
///   }
/// }
/// ```
public struct DSScrollStack<Content: View>: View {
  private let spacing: CGFloat
  private let horizontalPadding: CGFloat
  private let verticalPadding: CGFloat
  private let onRefresh: (() async -> Void)?
  private let content: Content

  public init(
    spacing: CGFloat = DSSpacing.md,
    horizontalPadding: CGFloat = DSSpacing.md,
    verticalPadding: CGFloat = DSSpacing.md,
    onRefresh: (() async -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.spacing = spacing
    self.horizontalPadding = horizontalPadding
    self.verticalPadding = verticalPadding
    self.onRefresh = onRefresh
    self.content = content()
  }

  public var body: some View {
    Group {
      if let onRefresh = self.onRefresh {
        self.scrollView.refreshable { await onRefresh() }
      } else {
        self.scrollView
      }
    }
  }

  private var scrollView: some View {
    ScrollView {
      self.stack
    }
    .scrollIndicators(.hidden)
  }

  private var stack: some View {
    LazyVStack(spacing: self.spacing) {
      self.content
    }
    .padding(.horizontal, self.horizontalPadding)
    .padding(.vertical, self.verticalPadding)
  }
}
