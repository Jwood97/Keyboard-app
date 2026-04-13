import SwiftUI

public struct DSFontSpec: Sendable {
  public let family: DSFontFamily
  public let weight: DSFontWeight
  public let size: CGFloat
  public let lineSpacing: CGFloat
  public let letterSpacing: CGFloat
  public let smallCaps: Bool

  public init(
    family: DSFontFamily,
    weight: DSFontWeight,
    size: CGFloat,
    lineSpacing: CGFloat = 0,
    letterSpacing: CGFloat = 0,
    smallCaps: Bool = false
  ) {
    self.family = family
    self.weight = weight
    self.size = size
    self.lineSpacing = lineSpacing
    self.letterSpacing = letterSpacing
    self.smallCaps = smallCaps
  }

  public var font: Font {
    let base = Font.ds(self.family, weight: self.weight, size: self.size)
    return self.smallCaps ? base.smallCaps() : base
  }
}

public enum DSTypography {
  public static let displayXL = DSFontSpec(family: .fraunces, weight: .bold, size: 52, lineSpacing: 6, letterSpacing: -0.8)
  public static let displayLarge = DSFontSpec(family: .fraunces, weight: .bold, size: 44, lineSpacing: 6, letterSpacing: -0.6)
  public static let display = DSFontSpec(family: .fraunces, weight: .semibold, size: 34, lineSpacing: 5, letterSpacing: -0.4)
  public static let titleLarge = DSFontSpec(family: .interDisplay, weight: .bold, size: 28, lineSpacing: 4, letterSpacing: -0.3)
  public static let title = DSFontSpec(family: .interDisplay, weight: .semibold, size: 22, lineSpacing: 4, letterSpacing: -0.2)
  public static let titleSmall = DSFontSpec(family: .interDisplay, weight: .semibold, size: 20, lineSpacing: 3, letterSpacing: -0.15)
  public static let headline = DSFontSpec(family: .inter, weight: .semibold, size: 17, lineSpacing: 3, letterSpacing: -0.1)
  public static let body = DSFontSpec(family: .inter, weight: .regular, size: 16, lineSpacing: 3)
  public static let bodyStrong = DSFontSpec(family: .inter, weight: .semibold, size: 16, lineSpacing: 3)
  public static let callout = DSFontSpec(family: .inter, weight: .medium, size: 15, lineSpacing: 3)
  public static let subhead = DSFontSpec(family: .inter, weight: .regular, size: 14, lineSpacing: 2)
  public static let footnote = DSFontSpec(family: .inter, weight: .regular, size: 13, lineSpacing: 2)
  public static let caption = DSFontSpec(family: .inter, weight: .regular, size: 12, lineSpacing: 2)
  public static let captionStrong = DSFontSpec(family: .inter, weight: .semibold, size: 12, lineSpacing: 2)
  public static let overline = DSFontSpec(family: .inter, weight: .semibold, size: 11, lineSpacing: 2, letterSpacing: 1.4, smallCaps: true)
  public static let quote = DSFontSpec(family: .frauncesText, weight: .regular, size: 17, lineSpacing: 4, letterSpacing: 0)
  public static let mono = DSFontSpec(family: .jetBrainsMono, weight: .regular, size: 14, lineSpacing: 2)
  public static let monoStrong = DSFontSpec(family: .jetBrainsMono, weight: .medium, size: 14, lineSpacing: 2)
  public static let keyLabel = DSFontSpec(family: .inter, weight: .medium, size: 22, lineSpacing: 0)
  public static let keyLabelSmall = DSFontSpec(family: .inter, weight: .medium, size: 13, lineSpacing: 0)
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
  case quote
  case mono
  case monoStrong

  public var spec: DSFontSpec {
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
      case .quote:
        return DSTypography.quote
      case .mono:
        return DSTypography.mono
      case .monoStrong:
        return DSTypography.monoStrong
    }
  }

  public var font: Font { self.spec.font }
  public var lineSpacing: CGFloat { self.spec.lineSpacing }
  public var letterSpacing: CGFloat { self.spec.letterSpacing }
}
