import SwiftUI

public enum DSColor {
  public enum Background {
    public static let canvas = Color.dynamic(
      light: Palette.Sand.shade50,
      dark: Palette.Sand.shade950
    )
    public static let surface = Color.dynamic(
      light: Palette.Neutral.pureWhite,
      dark: Color(hex: 0x1F1D19)
    )
    public static let elevated = Color.dynamic(
      light: Palette.Sand.shade50,
      dark: Color(hex: 0x26241F)
    )
    public static let raised = Color.dynamic(
      light: Palette.Sand.shade100,
      dark: Color(hex: 0x2E2B24)
    )
    public static let muted = Color.dynamic(
      light: Palette.Sand.shade100,
      dark: Color(hex: 0x1A1814)
    )
    public static let inverse = Color.dynamic(
      light: Palette.Matcha.shade800,
      dark: Palette.Sand.shade50
    )
    public static let overlay = Color.dynamic(
      light: Palette.Sand.shade950.opacity(0.35),
      dark: Palette.Sand.shade950.opacity(0.55)
    )
  }

  public enum Text {
    public static let primary = Color.dynamic(
      light: Palette.Matcha.shade950,
      dark: Color(hex: 0xEFEBDF)
    )
    public static let secondary = Color.dynamic(
      light: Palette.Sand.shade700,
      dark: Color(hex: 0xBFB8A6)
    )
    public static let tertiary = Color.dynamic(
      light: Palette.Sand.shade500,
      dark: Color(hex: 0x8A8472)
    )
    public static let placeholder = Color.dynamic(
      light: Palette.Sand.shade400,
      dark: Color(hex: 0x6D6758)
    )
    public static let disabled = Color.dynamic(
      light: Palette.Sand.shade400,
      dark: Palette.Sand.shade600
    )
    public static let onAccent = Color.dynamic(
      light: Palette.Sand.shade50,
      dark: Palette.Matcha.shade950
    )
    public static let onInverse = Color.dynamic(
      light: Palette.Sand.shade50,
      dark: Palette.Matcha.shade950
    )
    public static let link = Color.dynamic(
      light: Palette.Matcha.shade700,
      dark: Palette.Matcha.shade300
    )
  }

  public enum Border {
    public static let subtle = Color.dynamic(
      light: Palette.Sand.shade200,
      dark: Color(hex: 0x2C2923)
    )
    public static let `default` = Color.dynamic(
      light: Palette.Sand.shade300,
      dark: Color(hex: 0x3A362F)
    )
    public static let strong = Color.dynamic(
      light: Palette.Matcha.shade500,
      dark: Palette.Matcha.shade400
    )
    public static let focus = Color.dynamic(
      light: Palette.Matcha.shade600,
      dark: Palette.Matcha.shade300
    )
  }

  public enum Accent {
    public static let primary = Color.dynamic(
      light: Palette.Matcha.shade500,
      dark: Palette.Matcha.shade400
    )
    public static let primaryHover = Color.dynamic(
      light: Palette.Matcha.shade600,
      dark: Palette.Matcha.shade300
    )
    public static let primaryPressed = Color.dynamic(
      light: Palette.Matcha.shade700,
      dark: Palette.Matcha.shade500
    )
    public static let primarySoft = Color.dynamic(
      light: Palette.Matcha.shade100,
      dark: Palette.Matcha.shade800
    )
    public static let secondary = Color.dynamic(
      light: Palette.Peach.shade400,
      dark: Palette.Peach.shade300
    )
    public static let secondarySoft = Color.dynamic(
      light: Palette.Peach.shade50,
      dark: Palette.Peach.shade700.opacity(0.35)
    )
  }

  public enum Status {
    public static let success = Color.dynamic(
      light: Palette.Signal.success,
      dark: Color(hex: 0x8CB593)
    )
    public static let successSurface = Color.dynamic(
      light: Palette.Signal.successSoft,
      dark: Color(hex: 0x2B3A2F)
    )
    public static let warning = Color.dynamic(
      light: Palette.Signal.warning,
      dark: Color(hex: 0xE0B86B)
    )
    public static let warningSurface = Color.dynamic(
      light: Palette.Signal.warningSoft,
      dark: Color(hex: 0x3B2F18)
    )
    public static let danger = Color.dynamic(
      light: Palette.Signal.danger,
      dark: Color(hex: 0xE07862)
    )
    public static let dangerSurface = Color.dynamic(
      light: Palette.Signal.dangerSoft,
      dark: Color(hex: 0x3C241E)
    )
    public static let info = Color.dynamic(
      light: Palette.Signal.info,
      dark: Color(hex: 0x8FA9C6)
    )
    public static let infoSurface = Color.dynamic(
      light: Palette.Signal.infoSoft,
      dark: Color(hex: 0x1F2A36)
    )
  }

  public enum Gradient {
    public static let hero = LinearGradient(
      colors: [
        Color.dynamic(light: Palette.Matcha.shade200, dark: Palette.Matcha.shade900),
        Color.dynamic(light: Palette.Sand.shade50, dark: Palette.Sand.shade950)
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
    public static let accent = LinearGradient(
      colors: [Palette.Matcha.shade500, Palette.Matcha.shade700],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
    public static let warm = LinearGradient(
      colors: [Palette.Peach.shade300, Palette.Matcha.shade400],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
}
