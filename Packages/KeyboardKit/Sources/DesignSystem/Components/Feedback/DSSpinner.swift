import SwiftUI

public enum DSSpinnerStyle: Sendable {
  case arc
  case gradient
  case dots
  case dualRing
  case pulse
}

public enum DSSpinnerSize: Sendable {
  case small
  case medium
  case large
  case custom(CGFloat)

  public var value: CGFloat {
    switch self {
      case .small:
        return 16
      case .medium:
        return 24
      case .large:
        return 40
      case .custom(let size):
        return size
    }
  }
}

public struct DSSpinner: View {
  private let style: DSSpinnerStyle
  private let size: CGFloat
  private let tint: Color
  private let trackOpacity: Double

  public init(
    style: DSSpinnerStyle = .gradient,
    size: DSSpinnerSize = .medium,
    tint: Color = DSColor.Accent.primary,
    trackOpacity: Double = 0.14
  ) {
    self.style = style
    self.size = size.value
    self.tint = tint
    self.trackOpacity = trackOpacity
  }

  public init(
    style: DSSpinnerStyle = .gradient,
    size: CGFloat,
    tint: Color = DSColor.Accent.primary,
    trackOpacity: Double = 0.14
  ) {
    self.style = style
    self.size = size
    self.tint = tint
    self.trackOpacity = trackOpacity
  }

  public var body: some View {
    switch self.style {
      case .arc:
        ArcSpinner(size: self.size, tint: self.tint, trackOpacity: self.trackOpacity)
      case .gradient:
        GradientSpinner(size: self.size, tint: self.tint, trackOpacity: self.trackOpacity)
      case .dots:
        DotsSpinner(size: self.size, tint: self.tint)
      case .dualRing:
        DualRingSpinner(size: self.size, tint: self.tint, trackOpacity: self.trackOpacity)
      case .pulse:
        PulseSpinner(size: self.size, tint: self.tint)
    }
  }
}

private struct ArcSpinner: View {
  let size: CGFloat
  let tint: Color
  let trackOpacity: Double

  @State private var rotation: Double = 0
  @State private var trimEnd: CGFloat = 0.15

  var body: some View {
    let line = max(2, self.size / 10)
    return ZStack {
      Circle()
        .stroke(self.tint.opacity(self.trackOpacity), lineWidth: line)
      Circle()
        .trim(from: 0, to: self.trimEnd)
        .stroke(self.tint, style: StrokeStyle(lineWidth: line, lineCap: .round))
        .rotationEffect(.degrees(self.rotation))
    }
    .frame(width: self.size, height: self.size)
    .onAppear {
      withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
        self.rotation = 360
      }
      withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
        self.trimEnd = 0.82
      }
    }
  }
}

private struct GradientSpinner: View {
  let size: CGFloat
  let tint: Color
  let trackOpacity: Double

  @State private var rotation: Double = 0

  var body: some View {
    let line = max(2, self.size / 9)
    let gradient = AngularGradient(
      gradient: Gradient(stops: [
        .init(color: self.tint.opacity(0.0), location: 0.0),
        .init(color: self.tint.opacity(0.3), location: 0.35),
        .init(color: self.tint, location: 0.95),
        .init(color: self.tint.opacity(0.0), location: 1.0)
      ]),
      center: .center,
      startAngle: .degrees(0),
      endAngle: .degrees(360)
    )
    return ZStack {
      Circle()
        .stroke(self.tint.opacity(self.trackOpacity), lineWidth: line)
      Circle()
        .stroke(gradient, style: StrokeStyle(lineWidth: line, lineCap: .round))
      Circle()
        .fill(self.tint)
        .frame(width: line, height: line)
        .offset(y: -self.size / 2 + line / 2)
    }
    .frame(width: self.size, height: self.size)
    .rotationEffect(.degrees(self.rotation))
    .onAppear {
      withAnimation(.linear(duration: 0.95).repeatForever(autoreverses: false)) {
        self.rotation = 360
      }
    }
  }
}

private struct DotsSpinner: View {
  let size: CGFloat
  let tint: Color

  @State private var phase: Int = 0

  private let count: Int = 3

  var body: some View {
    let dot = max(4, self.size / 3.5)
    let spacing = max(2, dot / 2)
    return HStack(spacing: spacing) {
      ForEach(0..<self.count, id: \.self) { index in
        Circle()
          .fill(self.tint)
          .frame(width: dot, height: dot)
          .scaleEffect(self.phase == index ? 1.0 : 0.55)
          .opacity(self.phase == index ? 1.0 : 0.45)
      }
    }
    .frame(height: self.size, alignment: .center)
    .onAppear {
      Timer.scheduledTimer(withTimeInterval: 0.28, repeats: true) { _ in
        withAnimation(DSMotion.snappy) {
          self.phase = (self.phase + 1) % self.count
        }
      }
    }
  }
}

private struct DualRingSpinner: View {
  let size: CGFloat
  let tint: Color
  let trackOpacity: Double

  @State private var outerRotation: Double = 0
  @State private var innerRotation: Double = 0

  var body: some View {
    let outerLine = max(2, self.size / 12)
    let innerLine = max(1.5, self.size / 16)
    let innerInset = outerLine + 3
    return ZStack {
      Circle()
        .trim(from: 0, to: 0.7)
        .stroke(self.tint.opacity(0.85), style: StrokeStyle(lineWidth: outerLine, lineCap: .round))
        .rotationEffect(.degrees(self.outerRotation))
      Circle()
        .trim(from: 0, to: 0.4)
        .stroke(self.tint.opacity(0.45), style: StrokeStyle(lineWidth: innerLine, lineCap: .round))
        .padding(innerInset)
        .rotationEffect(.degrees(self.innerRotation))
    }
    .frame(width: self.size, height: self.size)
    .onAppear {
      withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
        self.outerRotation = 360
      }
      withAnimation(.linear(duration: 0.85).repeatForever(autoreverses: false)) {
        self.innerRotation = -360
      }
    }
  }
}

private struct PulseSpinner: View {
  let size: CGFloat
  let tint: Color

  @State private var scale: CGFloat = 0.6
  @State private var opacity: Double = 1.0

  var body: some View {
    ZStack {
      Circle()
        .fill(self.tint.opacity(0.2))
        .scaleEffect(self.scale)
        .opacity(self.opacity)
      Circle()
        .fill(self.tint)
        .frame(width: self.size * 0.45, height: self.size * 0.45)
    }
    .frame(width: self.size, height: self.size)
    .onAppear {
      withAnimation(.easeOut(duration: 1.3).repeatForever(autoreverses: false)) {
        self.scale = 1.0
        self.opacity = 0.0
      }
    }
  }
}
