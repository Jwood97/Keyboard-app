import SwiftUI

public struct DSFlowLayout: Layout {
  public var spacing: CGFloat
  public var rowSpacing: CGFloat
  public var alignment: HorizontalAlignment

  public init(
    spacing: CGFloat = DSSpacing.xs,
    rowSpacing: CGFloat = DSSpacing.xs,
    alignment: HorizontalAlignment = .leading
  ) {
    self.spacing = spacing
    self.rowSpacing = rowSpacing
    self.alignment = alignment
  }

  public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let maxWidth = proposal.width ?? .infinity
    let rows = self.arrangeRows(maxWidth: maxWidth, subviews: subviews)
    let width = rows.map { $0.width }.max() ?? 0
    let height = rows.reduce(into: CGFloat(0)) { partial, row in
      partial += row.height
    } + CGFloat(max(0, rows.count - 1)) * self.rowSpacing
    return CGSize(width: min(width, maxWidth), height: height)
  }

  public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    let rows = self.arrangeRows(maxWidth: bounds.width, subviews: subviews)
    var y = bounds.minY
    for row in rows {
      let rowHeight = row.height
      var x: CGFloat
      switch self.alignment {
        case .center:
          x = bounds.minX + (bounds.width - row.width) / 2
        case .trailing:
          x = bounds.maxX - row.width
        default:
          x = bounds.minX
      }
      for item in row.items {
        item.subview.place(
          at: CGPoint(x: x, y: y + (rowHeight - item.size.height) / 2),
          proposal: ProposedViewSize(width: item.size.width, height: item.size.height)
        )
        x += item.size.width + self.spacing
      }
      y += rowHeight + self.rowSpacing
    }
  }

  private struct Row {
    var items: [Item]
    var width: CGFloat
    var height: CGFloat
  }

  private struct Item {
    var subview: LayoutSubview
    var size: CGSize
  }

  private func arrangeRows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
    var rows: [Row] = []
    var current = Row(items: [], width: 0, height: 0)
    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      let additional = current.items.isEmpty ? size.width : size.width + self.spacing
      if current.width + additional > maxWidth, !current.items.isEmpty {
        rows.append(current)
        current = Row(items: [], width: 0, height: 0)
      }
      if !current.items.isEmpty {
        current.width += self.spacing
      }
      current.items.append(Item(subview: subview, size: size))
      current.width += size.width
      current.height = max(current.height, size.height)
    }
    if !current.items.isEmpty {
      rows.append(current)
    }
    return rows
  }
}
