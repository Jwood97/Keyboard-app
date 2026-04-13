import SwiftUI

public struct DSShimmer: ViewModifier {
  @State private var phase: CGFloat = -1

  public func body(content: Content) -> some View {
    content
      .overlay(
        GeometryReader { proxy in
          LinearGradient(
            colors: [
              .clear,
              DSColor.Text.onAccent.opacity(0.25),
              .clear
            ],
            startPoint: .leading,
            endPoint: .trailing
          )
          .frame(width: proxy.size.width * 0.6)
          .offset(x: self.phase * proxy.size.width)
          .blendMode(.plusLighter)
        }
        .mask(content)
      )
      .onAppear {
        withAnimation(DSMotion.shimmer) {
          self.phase = 2
        }
      }
  }
}

public extension View {
  func dsShimmer() -> some View {
    self.modifier(DSShimmer())
  }
}

public struct DSSkeleton: View {
  private let height: CGFloat
  private let cornerRadius: CGFloat

  public init(height: CGFloat = 16, cornerRadius: CGFloat = DSRadius.xs) {
    self.height = height
    self.cornerRadius = cornerRadius
  }

  public var body: some View {
    RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
      .fill(DSColor.Background.raised)
      .frame(height: self.height)
      .dsShimmer()
  }
}
