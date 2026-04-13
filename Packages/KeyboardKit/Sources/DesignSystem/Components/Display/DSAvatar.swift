import SwiftUI

public enum DSAvatarSize: Sendable {
  case xs
  case sm
  case md
  case lg
  case xl

  public var diameter: CGFloat {
    switch self {
      case .xs:
        return 24
      case .sm:
        return 32
      case .md:
        return 44
      case .lg:
        return 56
      case .xl:
        return 80
    }
  }

  public var fontSize: CGFloat {
    switch self {
      case .xs:
        return 10
      case .sm:
        return 13
      case .md:
        return 16
      case .lg:
        return 20
      case .xl:
        return 28
    }
  }
}

public enum DSAvatarContent: Sendable {
  case initials(String)
  case systemIcon(String)
}

public struct DSAvatar: View {
  private let content: DSAvatarContent
  private let size: DSAvatarSize
  private let tint: Color

  public init(
    _ content: DSAvatarContent,
    size: DSAvatarSize = .md,
    tint: Color = DSColor.Accent.primary
  ) {
    self.content = content
    self.size = size
    self.tint = tint
  }

  public var body: some View {
    ZStack {
      Circle()
        .fill(self.tint.opacity(0.18))
      Circle()
        .stroke(self.tint.opacity(0.35), lineWidth: 1)
      self.inner
    }
    .frame(width: self.size.diameter, height: self.size.diameter)
  }

  @ViewBuilder
  private var inner: some View {
    switch self.content {
      case let .initials(value):
        Text(Self.initials(from: value))
          .font(.system(size: self.size.fontSize, weight: .semibold, design: .rounded))
          .foregroundStyle(self.tint)
      case let .systemIcon(name):
        Image(systemName: name)
          .font(.system(size: self.size.fontSize, weight: .semibold))
          .foregroundStyle(self.tint)
    }
  }

  private static func initials(from value: String) -> String {
    let parts = value.split(separator: " ").prefix(2)
    let letters = parts.compactMap { $0.first }
    return String(letters).uppercased()
  }
}
