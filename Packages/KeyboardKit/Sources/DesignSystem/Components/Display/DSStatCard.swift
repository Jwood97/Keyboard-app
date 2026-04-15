import SwiftUI

public enum DSStatTrend: Sendable {
  case up(String)
  case down(String)
  case neutral(String)

  public var label: String {
    switch self {
      case .up(let s), .down(let s), .neutral(let s):
        return s
    }
  }
}

public struct DSStatCard: View {
  private let title: String
  private let value: String
  private let subtitle: String?
  private let icon: DSIcon?
  private let tint: Color
  private let trend: DSStatTrend?

  public init(
    title: String,
    value: String,
    subtitle: String? = nil,
    icon: DSIcon? = nil,
    tint: Color = DSColor.Accent.primary,
    trend: DSStatTrend? = nil
  ) {
    self.title = title
    self.value = value
    self.subtitle = subtitle
    self.icon = icon
    self.tint = tint
    self.trend = trend
  }

  public var body: some View {
    DSCard(style: .bordered, padding: DSSpacing.md) {
      VStack(alignment: .leading, spacing: DSSpacing.xs) {
        HStack(spacing: DSSpacing.xs) {
          if let icon = self.icon {
            ZStack {
              RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                .fill(self.tint.opacity(DSOpacity.soft))
              DSIconView(icon, weight: .regular, size: 16, tint: self.tint)
            }
            .frame(width: 32, height: 32)
          }
          DSText(self.title, style: .footnote, color: DSColor.Text.secondary)
          Spacer(minLength: 0)
        }
        DSText(self.value, style: .titleLarge)
          .contentTransition(.numericText())
        HStack(spacing: DSSpacing.xs) {
          if let trend = self.trend {
            self.trendBadge(trend)
          }
          if let subtitle = self.subtitle {
            DSText(subtitle, style: .caption, color: DSColor.Text.tertiary)
          }
        }
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(self.title): \(self.value)")
  }

  @ViewBuilder
  private func trendBadge(_ trend: DSStatTrend) -> some View {
    HStack(spacing: 2) {
      DSIconView(self.trendIcon(for: trend), weight: .fill, size: 10, tint: self.trendColor(for: trend))
      DSText(trend.label, style: .caption, color: self.trendColor(for: trend))
    }
    .padding(.horizontal, 6)
    .padding(.vertical, 2)
    .background(
      Capsule()
        .fill(self.trendColor(for: trend).opacity(DSOpacity.soft))
    )
  }

  private func trendIcon(for trend: DSStatTrend) -> DSIcon {
    switch trend {
      case .up:
        return DSIcon.arrowUpRight
      case .down:
        return DSIcon.arrowDownRight
      case .neutral:
        return DSIcon.minus
    }
  }

  private func trendColor(for trend: DSStatTrend) -> Color {
    switch trend {
      case .up:
        return DSColor.Status.success
      case .down:
        return DSColor.Status.danger
      case .neutral:
        return DSColor.Text.secondary
    }
  }
}
