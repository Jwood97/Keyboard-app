import SwiftUI

public enum DSTypography {
  public static let displayXL = Font.system(size: 52, weight: .bold, design: .serif)
  public static let displayLarge = Font.system(size: 44, weight: .bold, design: .serif)
  public static let display = Font.system(size: 34, weight: .semibold, design: .serif)
  public static let titleLarge = Font.system(size: 28, weight: .semibold, design: .rounded)
  public static let title = Font.system(size: 22, weight: .semibold, design: .rounded)
  public static let titleSmall = Font.system(size: 20, weight: .semibold, design: .rounded)
  public static let headline = Font.system(size: 17, weight: .semibold, design: .default)
  public static let body = Font.system(size: 16, weight: .regular, design: .default)
  public static let bodyStrong = Font.system(size: 16, weight: .semibold, design: .default)
  public static let callout = Font.system(size: 15, weight: .medium, design: .default)
  public static let subhead = Font.system(size: 14, weight: .regular, design: .default)
  public static let footnote = Font.system(size: 13, weight: .regular, design: .default)
  public static let caption = Font.system(size: 12, weight: .regular, design: .default)
  public static let captionStrong = Font.system(size: 12, weight: .semibold, design: .default)
  public static let overline = Font.system(size: 11, weight: .semibold, design: .default).uppercaseSmallCaps()
  public static let mono = Font.system(size: 14, weight: .regular, design: .monospaced)
  public static let keyLabel = Font.system(size: 22, weight: .medium, design: .rounded)
  public static let keyLabelSmall = Font.system(size: 13, weight: .medium, design: .rounded)
}

public enum DSTextStyle: Sendable {
  case displayXL
  case displayLarge
  case display
  case titleLarge
  case title
  case titleSmall
  case headline
  case body
  case bodyStrong
  case callout
  case subhead
  case footnote
  case caption
  case captionStrong
  case overline

  public var font: Font {
    switch self {
      case .displayXL:
        return DSTypography.displayXL
      case .displayLarge:
        return DSTypography.displayLarge
      case .display:
        return DSTypography.display
      case .titleLarge:
        return DSTypography.titleLarge
      case .title:
        return DSTypography.title
      case .titleSmall:
        return DSTypography.titleSmall
      case .headline:
        return DSTypography.headline
      case .body:
        return DSTypography.body
      case .bodyStrong:
        return DSTypography.bodyStrong
      case .callout:
        return DSTypography.callout
      case .subhead:
        return DSTypography.subhead
      case .footnote:
        return DSTypography.footnote
      case .caption:
        return DSTypography.caption
      case .captionStrong:
        return DSTypography.captionStrong
      case .overline:
        return DSTypography.overline
    }
  }

  public var lineSpacing: CGFloat {
    switch self {
      case .displayXL, .displayLarge, .display:
        return 6
      case .titleLarge, .title, .titleSmall:
        return 4
      case .headline, .body, .bodyStrong, .callout:
        return 3
      case .subhead, .footnote, .caption, .captionStrong, .overline:
        return 2
    }
  }

  public var letterSpacing: CGFloat {
    switch self {
      case .displayXL, .displayLarge, .display:
        return -0.5
      case .overline:
        return 1.2
      default:
        return 0
    }
  }
}
