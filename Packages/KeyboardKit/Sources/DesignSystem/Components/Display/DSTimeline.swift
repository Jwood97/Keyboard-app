import SwiftUI

public struct DSTimelineEvent: Identifiable, Sendable {
  public let id = UUID()
  public let title: String
  public let subtitle: String?
  public let timestamp: String?
  public let icon: DSIcon?
  public let tint: Color

  public init(
    title: String,
    subtitle: String? = nil,
    timestamp: String? = nil,
    icon: DSIcon? = nil,
    tint: Color = DSColor.Accent.primary
  ) {
    self.title = title
    self.subtitle = subtitle
    self.timestamp = timestamp
    self.icon = icon
    self.tint = tint
  }
}

public struct DSTimeline: View {
  private let events: [DSTimelineEvent]

  public init(events: [DSTimelineEvent]) {
    self.events = events
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(Array(self.events.enumerated()), id: \.element.id) { index, event in
        HStack(alignment: .top, spacing: DSSpacing.sm) {
          VStack(spacing: 0) {
            ZStack {
              Circle()
                .fill(event.tint.opacity(DSOpacity.soft))
                .frame(width: 32, height: 32)
              if let icon = event.icon {
                DSIconView(icon, weight: .fill, size: 14, tint: event.tint)
              } else {
                Circle()
                  .fill(event.tint)
                  .frame(width: 8, height: 8)
              }
            }
            if index < self.events.count - 1 {
              Rectangle()
                .fill(DSColor.Border.subtle)
                .frame(width: 2)
                .frame(maxHeight: .infinity)
            }
          }
          VStack(alignment: .leading, spacing: 4) {
            HStack {
              DSText(event.title, style: .bodyStrong)
              Spacer(minLength: DSSpacing.xs)
              if let timestamp = event.timestamp {
                DSText(timestamp, style: .caption, color: DSColor.Text.tertiary)
              }
            }
            if let subtitle = event.subtitle {
              DSText(subtitle, style: .footnote, color: DSColor.Text.secondary)
            }
          }
          .padding(.bottom, index < self.events.count - 1 ? DSSpacing.md : 0)
        }
      }
    }
  }
}
