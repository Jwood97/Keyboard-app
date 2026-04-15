import SwiftUI

public enum DSPopoverDirection: Sendable {
  case top
  case bottom
  case leading
  case trailing
}

public struct DSPopover<PopoverContent: View>: ViewModifier {
  @Binding var isPresented: Bool
  let direction: DSPopoverDirection
  let arrowSize: CGFloat
  let popoverContent: () -> PopoverContent

  public func body(content: Content) -> some View {
    content.overlay(alignment: self.alignment) {
      if self.isPresented {
        VStack(spacing: 0) {
          if self.direction == .bottom {
            DSPopoverArrow(direction: .up)
              .frame(width: self.arrowSize * 1.5, height: self.arrowSize)
              .foregroundStyle(DSColor.Background.surface)
          }
          self.popoverContent()
            .padding(DSSpacing.sm)
            .background(
              RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                .fill(DSColor.Background.surface)
            )
            .overlay(
              RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                .strokeBorder(DSColor.Border.subtle, lineWidth: 1)
            )
          if self.direction == .top {
            DSPopoverArrow(direction: .down)
              .frame(width: self.arrowSize * 1.5, height: self.arrowSize)
              .foregroundStyle(DSColor.Background.surface)
          }
        }
        .dsShadow(DSElevation.md)
        .offset(self.offset)
        .transition(.scale(scale: 0.92).combined(with: .opacity))
        .zIndex(DSZIndex.tooltip)
      }
    }
    .dsAnimation(DSMotion.snappy, value: self.isPresented)
  }

  private var alignment: Alignment {
    switch self.direction {
      case .top:
        return .top
      case .bottom:
        return .bottom
      case .leading:
        return .leading
      case .trailing:
        return .trailing
    }
  }

  private var offset: CGSize {
    let gap: CGFloat = 4
    switch self.direction {
      case .top:
        return CGSize(width: 0, height: -44 - gap)
      case .bottom:
        return CGSize(width: 0, height: 44 + gap)
      case .leading:
        return CGSize(width: -44 - gap, height: 0)
      case .trailing:
        return CGSize(width: 44 + gap, height: 0)
    }
  }
}

private struct DSPopoverArrow: Shape {
  enum Direction {
    case up
    case down
  }

  let direction: Direction

  func path(in rect: CGRect) -> Path {
    var path = Path()
    switch self.direction {
      case .up:
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
      case .down:
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
    }
    path.closeSubpath()
    return path
  }
}

public struct DSTooltip: View {
  private let text: String

  public init(_ text: String) {
    self.text = text
  }

  public var body: some View {
    DSText(self.text, style: .caption, color: DSColor.Text.primary)
      .padding(.horizontal, DSSpacing.sm)
      .padding(.vertical, DSSpacing.xxs)
      .background(
        RoundedRectangle(cornerRadius: DSRadius.xs, style: .continuous)
          .fill(DSColor.Background.surface)
      )
      .overlay(
        RoundedRectangle(cornerRadius: DSRadius.xs, style: .continuous)
          .strokeBorder(DSColor.Border.subtle, lineWidth: 1)
      )
      .dsShadow(DSElevation.sm)
  }
}

public extension View {
  func dsPopover<PopoverContent: View>(
    isPresented: Binding<Bool>,
    direction: DSPopoverDirection = .bottom,
    @ViewBuilder content: @escaping () -> PopoverContent
  ) -> some View {
    self.modifier(DSPopover(
      isPresented: isPresented,
      direction: direction,
      arrowSize: 6,
      popoverContent: content
    ))
  }
}
