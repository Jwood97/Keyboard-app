import SwiftUI

public enum DSImageSource: Sendable {
  case url(URL?)
  case systemImage(String)
  case icon(DSIcon, DSIconWeight)
}

public enum DSImageAspect: Sendable {
  case fit
  case fill
  case square
}

public struct DSImage: View {
  private let source: DSImageSource
  private let aspect: DSImageAspect
  private let cornerRadius: CGFloat
  private let placeholderText: String?

  public init(
    _ source: DSImageSource,
    aspect: DSImageAspect = .fill,
    cornerRadius: CGFloat = DSRadius.md,
    placeholderText: String? = nil
  ) {
    self.source = source
    self.aspect = aspect
    self.cornerRadius = cornerRadius
    self.placeholderText = placeholderText
  }

  public var body: some View {
    Group {
      switch self.source {
        case .url(let url):
          self.remoteImage(url: url)
        case .systemImage(let name):
          Image(systemName: name)
            .resizable()
            .aspectRatio(contentMode: self.contentMode)
            .foregroundStyle(DSColor.Text.secondary)
        case .icon(let icon, let weight):
          DSIconView(icon, weight: weight, size: 40, tint: DSColor.Text.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DSColor.Background.raised)
      }
    }
    .modifier(DSImageAspectModifier(aspect: self.aspect))
    .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous))
  }

  @ViewBuilder
  private func remoteImage(url: URL?) -> some View {
    AsyncImage(url: url, transaction: Transaction(animation: DSMotion.gentle)) { phase in
      switch phase {
        case .empty:
          self.loadingState
        case .success(let image):
          image
            .resizable()
            .aspectRatio(contentMode: self.contentMode)
            .transition(.opacity)
        case .failure:
          self.errorState
        @unknown default:
          self.loadingState
      }
    }
  }

  private var loadingState: some View {
    Rectangle()
      .fill(DSColor.Background.raised)
      .dsShimmer()
  }

  private var errorState: some View {
    ZStack {
      DSColor.Background.raised
      VStack(spacing: DSSpacing.xxs) {
        DSIconView(DSIcon.warning, weight: .regular, size: 18, tint: DSColor.Text.tertiary)
        if let text = self.placeholderText {
          DSText(text, style: .caption, color: DSColor.Text.tertiary, alignment: .center)
        }
      }
    }
  }

  private var contentMode: ContentMode {
    switch self.aspect {
      case .fit:
        return .fit
      case .fill, .square:
        return .fill
    }
  }
}

private struct DSImageAspectModifier: ViewModifier {
  let aspect: DSImageAspect

  func body(content: Content) -> some View {
    switch self.aspect {
      case .square:
        content.aspectRatio(1, contentMode: .fill)
      case .fit, .fill:
        content
    }
  }
}
