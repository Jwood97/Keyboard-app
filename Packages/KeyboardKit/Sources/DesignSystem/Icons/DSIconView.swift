import SwiftUI

public struct DSIconView: View {
  private let icon: DSIcon
  private let weight: DSIconWeight
  private let size: CGFloat
  private let tint: Color?

  public init(
    _ icon: DSIcon,
    weight: DSIconWeight = .regular,
    size: CGFloat = DSIconSize.md,
    tint: Color? = nil
  ) {
    self.icon = icon
    self.weight = weight
    self.size = size
    self.tint = tint
  }

  public var body: some View {
    Image(self.icon.resolvedAssetName(weight: self.weight), bundle: .module)
      .renderingMode(.template)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: self.size, height: self.size)
      .foregroundStyle(self.tint ?? DSColor.Text.primary)
      .accessibilityHidden(true)
  }
}

public extension View {
  func dsIcon(_ icon: DSIcon, weight: DSIconWeight = .regular, size: CGFloat = DSIconSize.md, tint: Color? = nil) -> some View {
    DSIconView(icon, weight: weight, size: size, tint: tint)
  }
}
