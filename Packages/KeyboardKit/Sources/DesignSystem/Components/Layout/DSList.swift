import SwiftUI

/// Native List–backed scrollable container. Backed by UICollectionView on iOS 16+,
/// giving automatic cell reuse and smooth performance at any scale.
///
/// **When to use:**
/// - 20+ items or unbounded / dynamic datasets
/// - Swipe-to-delete via `ForEach.onDelete`
/// - Row reordering via `ForEach.onMove` + `EditButton`
/// - Pull-to-refresh via `onRefresh`
///
/// **When NOT to use:**
/// - Fewer than ~20 static items → use `DSScrollStack` or plain `VStack`
/// - Custom card feeds mixing heterogeneous content → use `DSScrollStack`
///
/// **Usage:**
/// ```swift
/// DSList {
///   ForEach(items) { item in
///     DSListRow(item.title, icon: item.icon, action: {})
///     DSDivider()
///   }
///   .onDelete { items.remove(atOffsets: $0) }
/// }
/// ```
public struct DSList<Content: View>: View {
  private let onRefresh: (() async -> Void)?
  private let content: Content

  public init(
    onRefresh: (() async -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.onRefresh = onRefresh
    self.content = content()
  }

  public var body: some View {
    Group {
      if let onRefresh = self.onRefresh {
        self.coreList.refreshable { await onRefresh() }
      } else {
        self.coreList
      }
    }
  }

  private var coreList: some View {
    List {
      self.content
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(DSColor.Background.canvas)
  }
}
