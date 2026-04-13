import SwiftUI
#if canImport(CoreGraphics)
import CoreGraphics
#endif
#if canImport(CoreText)
import CoreText
#endif

public enum DSFontFamily: String, Sendable, CaseIterable {
  case fraunces
  case frauncesText
  case inter
  case interDisplay
  case jetBrainsMono

  public var displayName: String {
    switch self {
      case .fraunces:
        return "Fraunces (72pt Display)"
      case .frauncesText:
        return "Fraunces (9pt Text)"
      case .inter:
        return "Inter"
      case .interDisplay:
        return "Inter Display"
      case .jetBrainsMono:
        return "JetBrains Mono"
    }
  }
}

public enum DSFontWeight: Sendable {
  case regular
  case medium
  case semibold
  case bold

  public var uiWeight: Font.Weight {
    switch self {
      case .regular:
        return .regular
      case .medium:
        return .medium
      case .semibold:
        return .semibold
      case .bold:
        return .bold
    }
  }
}

public struct DSFontFace: Sendable {
  public let family: DSFontFamily
  public let weight: DSFontWeight
  public let postScriptName: String
  public let fileName: String

  public init(family: DSFontFamily, weight: DSFontWeight, postScriptName: String, fileName: String) {
    self.family = family
    self.weight = weight
    self.postScriptName = postScriptName
    self.fileName = fileName
  }
}

public enum DSFontCatalog {
  public static let all: [DSFontFace] = [
    .init(family: .fraunces, weight: .regular, postScriptName: "Fraunces72pt-Regular", fileName: "Fraunces72pt-Regular.ttf"),
    .init(family: .fraunces, weight: .semibold, postScriptName: "Fraunces72pt-SemiBold", fileName: "Fraunces72pt-SemiBold.ttf"),
    .init(family: .fraunces, weight: .bold, postScriptName: "Fraunces72pt-Bold", fileName: "Fraunces72pt-Bold.ttf"),
    .init(family: .frauncesText, weight: .regular, postScriptName: "Fraunces9pt-Regular", fileName: "Fraunces9pt-Regular.ttf"),
    .init(family: .frauncesText, weight: .semibold, postScriptName: "Fraunces9pt-SemiBold", fileName: "Fraunces9pt-SemiBold.ttf"),
    .init(family: .inter, weight: .regular, postScriptName: "Inter-Regular", fileName: "Inter-Regular.ttf"),
    .init(family: .inter, weight: .medium, postScriptName: "Inter-Medium", fileName: "Inter-Medium.ttf"),
    .init(family: .inter, weight: .semibold, postScriptName: "Inter-SemiBold", fileName: "Inter-SemiBold.ttf"),
    .init(family: .inter, weight: .bold, postScriptName: "Inter-Bold", fileName: "Inter-Bold.ttf"),
    .init(family: .interDisplay, weight: .semibold, postScriptName: "InterDisplay-SemiBold", fileName: "InterDisplay-SemiBold.ttf"),
    .init(family: .interDisplay, weight: .bold, postScriptName: "InterDisplay-Bold", fileName: "InterDisplay-Bold.ttf"),
    .init(family: .jetBrainsMono, weight: .regular, postScriptName: "JetBrainsMono-Regular", fileName: "JetBrainsMono-Regular.ttf"),
    .init(family: .jetBrainsMono, weight: .medium, postScriptName: "JetBrainsMono-Medium", fileName: "JetBrainsMono-Medium.ttf")
  ]

  public static func face(family: DSFontFamily, weight: DSFontWeight) -> DSFontFace {
    if let exact = self.all.first(where: { $0.family == family && $0.weight == weight }) {
      return exact
    }
    let familyFaces = self.all.filter { $0.family == family }
    let preferred: [DSFontWeight] = [.semibold, .medium, .bold, .regular]
    for candidate in preferred {
      if let fallback = familyFaces.first(where: { $0.weight == candidate }) {
        return fallback
      }
    }
    return familyFaces.first ?? self.all[0]
  }
}

public enum DSFontRegistry {
  private static let registered: Void = DSFontRegistry.performRegistration()

  public static func ensureRegistered() {
    _ = self.registered
  }

  private static func performRegistration() {
    #if canImport(CoreText)
    for face in DSFontCatalog.all {
      let base = (face.fileName as NSString).deletingPathExtension
      let ext = (face.fileName as NSString).pathExtension
      guard let url = Bundle.module.url(forResource: base, withExtension: ext) else { continue }
      var error: Unmanaged<CFError>?
      if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
        continue
      }
    }
    #endif
  }
}

public extension Font {
  static func ds(_ family: DSFontFamily, weight: DSFontWeight, size: CGFloat) -> Font {
    DSFontRegistry.ensureRegistered()
    let face = DSFontCatalog.face(family: family, weight: weight)
    return Font.custom(face.postScriptName, size: size)
  }
}
