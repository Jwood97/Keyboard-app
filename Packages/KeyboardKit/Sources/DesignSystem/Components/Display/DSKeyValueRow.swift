import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum DSKeyValueOrientation: Sendable {
  case horizontal
  case vertical
}

public struct DSKeyValueRow: View {
  private let key: String
  private let value: String
  private let icon: DSIcon?
  private let orientation: DSKeyValueOrientation
  private let valueStyle: DSTextStyle
  private let copyable: Bool
  private let action: (() -> Void)?

  public init(
    _ key: String,
    value: String,
    icon: DSIcon? = nil,
    orientation: DSKeyValueOrientation = .horizontal,
    valueStyle: DSTextStyle = .bodyStrong,
    copyable: Bool = false,
    action: (() -> Void)? = nil
  ) {
    self.key = key
    self.value = value
    self.icon = icon
    self.orientation = orientation
    self.valueStyle = valueStyle
    self.copyable = copyable
    self.action = action
  }

  public var body: some View {
    Group {
      switch self.orientation {
        case .horizontal:
          HStack(spacing: DSSpacing.sm) {
            self.keyView
            Spacer(minLength: DSSpacing.sm)
            self.valueView
            self.trailingIcon
          }
        case .vertical:
          VStack(alignment: .leading, spacing: 4) {
            self.keyView
            HStack(spacing: DSSpacing.xs) {
              self.valueView
              self.trailingIcon
            }
          }
      }
    }
    .contentShape(Rectangle())
    .padding(.vertical, DSSpacing.xs)
    .onTapGesture {
      self.handleTap()
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(self.key), \(self.value)")
  }

  private var keyView: some View {
    HStack(spacing: DSSpacing.xs) {
      if let icon = self.icon {
        DSIconView(icon, weight: .regular, size: 14, tint: DSColor.Text.tertiary)
      }
      DSText(self.key, style: .footnote, color: DSColor.Text.secondary)
    }
  }

  private var valueView: some View {
    DSText(self.value, style: self.valueStyle, alignment: .trailing)
      .lineLimit(1)
      .truncationMode(.middle)
  }

  @ViewBuilder
  private var trailingIcon: some View {
    if self.copyable {
      DSIconView(DSIcon.UI.copy, weight: .regular, size: 14, tint: DSColor.Text.tertiary)
    } else if self.action != nil {
      DSIconView(DSIcon.UI.chevronRight, weight: .regular, size: 12, tint: DSColor.Text.tertiary)
    }
  }

  private func handleTap() {
    if self.copyable {
#if canImport(UIKit)
      UIPasteboard.general.string = self.value
#endif
      DSHaptics.notify(.success)
    }
    self.action?()
  }
}
