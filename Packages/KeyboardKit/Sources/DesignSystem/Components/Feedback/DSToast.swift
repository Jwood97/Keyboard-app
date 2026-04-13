import SwiftUI

public struct DSToast: Identifiable, Equatable {
  public let id = UUID()
  public let title: String
  public let message: String?
  public let kind: DSMessageKind
  public let duration: TimeInterval

  public init(
    title: String,
    message: String? = nil,
    kind: DSMessageKind = .info,
    duration: TimeInterval = 3.0
  ) {
    self.title = title
    self.message = message
    self.kind = kind
    self.duration = duration
  }
}

@MainActor
public final class DSToastCenter: ObservableObject {
  @Published public private(set) var current: DSToast?
  private var dismissTask: Task<Void, Never>?

  public init() {}

  public func present(_ toast: DSToast) {
    self.dismissTask?.cancel()
    self.current = toast
    self.dismissTask = Task { [weak self] in
      try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))
      guard !Task.isCancelled else { return }
      await MainActor.run {
        self?.current = nil
      }
    }
  }

  public func dismiss() {
    self.dismissTask?.cancel()
    self.current = nil
  }
}

public struct DSToastView: View {
  private let toast: DSToast

  public init(_ toast: DSToast) {
    self.toast = toast
  }

  public var body: some View {
    HStack(spacing: DSSpacing.sm) {
      Image(systemName: self.iconName)
        .font(.system(size: 18, weight: .semibold))
        .foregroundStyle(self.tint)
      VStack(alignment: .leading, spacing: 2) {
        DSText(self.toast.title, style: .bodyStrong, color: DSColor.Text.onInverse)
        if let message = self.toast.message {
          DSText(message, style: .footnote, color: DSColor.Text.onInverse.opacity(0.75))
        }
      }
      Spacer(minLength: DSSpacing.xs)
    }
    .padding(DSSpacing.md)
    .background(
      RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
        .fill(DSColor.Background.inverse)
    )
    .dsShadow(DSElevation.lg)
  }

  private var iconName: String {
    switch self.toast.kind {
      case .info:
        return "info.circle.fill"
      case .success:
        return "checkmark.seal.fill"
      case .warning:
        return "exclamationmark.triangle.fill"
      case .error:
        return "xmark.octagon.fill"
    }
  }

  private var tint: Color {
    switch self.toast.kind {
      case .info:
        return DSColor.Status.info
      case .success:
        return DSColor.Status.success
      case .warning:
        return DSColor.Status.warning
      case .error:
        return DSColor.Status.danger
    }
  }
}

public struct DSToastLayer: ViewModifier {
  @ObservedObject var center: DSToastCenter

  public func body(content: Content) -> some View {
    content
      .overlay(alignment: .top) {
        if let toast = self.center.current {
          DSToastView(toast)
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, DSSpacing.xs)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onTapGesture {
              self.center.dismiss()
            }
        }
      }
      .animation(DSMotion.emphasised, value: self.center.current)
  }
}

public extension View {
  func dsToastLayer(_ center: DSToastCenter) -> some View {
    self.modifier(DSToastLayer(center: center))
  }
}
