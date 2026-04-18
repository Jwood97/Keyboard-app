import SwiftUI

public struct DSStep: Identifiable, Sendable {
  public let id: Int
  public let title: String
  public let subtitle: String?

  public init(id: Int, title: String, subtitle: String? = nil) {
    self.id = id
    self.title = title
    self.subtitle = subtitle
  }
}

public enum DSStepIndicatorOrientation: Sendable {
  case horizontal
  case vertical
}

public struct DSStepIndicator: View {
  private let steps: [DSStep]
  private let currentStep: Int
  private let orientation: DSStepIndicatorOrientation

  public init(
    steps: [DSStep],
    currentStep: Int,
    orientation: DSStepIndicatorOrientation = .horizontal
  ) {
    self.steps = steps
    self.currentStep = currentStep
    self.orientation = orientation
  }

  public var body: some View {
    Group {
      switch self.orientation {
        case .horizontal:
          self.horizontalBody
        case .vertical:
          self.verticalBody
      }
    }
    .dsAnimation(DSMotion.refined, value: self.currentStep)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Step \(self.currentStep + 1) of \(self.steps.count): \(self.steps[min(self.currentStep, self.steps.count - 1)].title)")
  }

  private var horizontalBody: some View {
    HStack(alignment: .top, spacing: 0) {
      ForEach(Array(self.steps.enumerated()), id: \.element.id) { index, step in
        VStack(spacing: DSSpacing.xs) {
          self.bubble(for: index)
          DSText(
            step.title,
            style: .caption,
            color: index <= self.currentStep ? DSColor.Text.primary : DSColor.Text.tertiary,
            alignment: .center
          )
          .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        if index < self.steps.count - 1 {
          Rectangle()
            .fill(index < self.currentStep ? DSColor.Accent.primary : DSColor.Border.subtle)
            .frame(height: 2)
            .offset(y: 14)
        }
      }
    }
  }

  private var verticalBody: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(Array(self.steps.enumerated()), id: \.element.id) { index, step in
        HStack(alignment: .top, spacing: DSSpacing.sm) {
          VStack(spacing: 0) {
            self.bubble(for: index)
            if index < self.steps.count - 1 {
              Rectangle()
                .fill(index < self.currentStep ? DSColor.Accent.primary : DSColor.Border.subtle)
                .frame(width: 2)
                .frame(maxHeight: .infinity)
            }
          }
          VStack(alignment: .leading, spacing: 2) {
            DSText(
              step.title,
              style: .bodyStrong,
              color: index <= self.currentStep ? DSColor.Text.primary : DSColor.Text.tertiary
            )
            if let subtitle = step.subtitle {
              DSText(subtitle, style: .caption, color: DSColor.Text.secondary)
            }
          }
          .padding(.bottom, DSSpacing.md)
        }
      }
    }
  }

  @ViewBuilder
  private func bubble(for index: Int) -> some View {
    ZStack {
      Circle()
        .fill(self.bubbleColor(for: index))
        .frame(width: 28, height: 28)
        .overlay(
          Circle()
            .strokeBorder(
              index == self.currentStep ? DSColor.Accent.primary : .clear,
              lineWidth: 2
            )
            .frame(width: 32, height: 32)
        )
      if index < self.currentStep {
        DSIconView(DSIcon.UI.check, weight: .fill, size: 12, tint: DSColor.Text.onAccent)
      } else {
        DSText(
          "\(index + 1)",
          style: .captionStrong,
          color: index == self.currentStep ? DSColor.Text.onAccent : DSColor.Text.tertiary,
          alignment: .center
        )
      }
    }
  }

  private func bubbleColor(for index: Int) -> Color {
    if index < self.currentStep {
      return DSColor.Accent.primary
    } else if index == self.currentStep {
      return DSColor.Accent.primary
    } else {
      return DSColor.Background.raised
    }
  }
}
