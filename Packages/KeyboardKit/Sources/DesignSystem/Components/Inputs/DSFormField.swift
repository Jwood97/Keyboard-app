import SwiftUI

public struct DSFormField<Content: View>: View {
  private let title: String?
  private let helperText: String?
  private let errorText: String?
  private let isRequired: Bool
  private let trailingAccessory: AnyView?
  private let content: Content

  public init(
    _ title: String? = nil,
    helperText: String? = nil,
    errorText: String? = nil,
    isRequired: Bool = false,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.helperText = helperText
    self.errorText = errorText
    self.isRequired = isRequired
    self.trailingAccessory = nil
    self.content = content()
  }

  public init<Accessory: View>(
    _ title: String? = nil,
    helperText: String? = nil,
    errorText: String? = nil,
    isRequired: Bool = false,
    @ViewBuilder trailingAccessory: () -> Accessory,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.helperText = helperText
    self.errorText = errorText
    self.isRequired = isRequired
    self.trailingAccessory = AnyView(trailingAccessory())
    self.content = content()
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.xs) {
      if self.title != nil || self.trailingAccessory != nil {
        HStack(spacing: DSSpacing.xxs) {
          if let title = self.title {
            DSText(title, style: .captionStrong, color: DSColor.Text.secondary)
            if self.isRequired {
              DSText("*", style: .captionStrong, color: DSColor.Status.danger)
            }
          }
          Spacer(minLength: DSSpacing.xs)
          if let accessory = self.trailingAccessory {
            accessory
          }
        }
      }
      self.content
      if let message = self.effectiveMessage {
        HStack(spacing: DSSpacing.xxs) {
          if self.errorText != nil {
            DSIconView(DSIcon.Status.error, weight: .fill, size: 12, tint: DSColor.Status.danger)
          }
          DSText(message, style: .caption, color: self.errorText != nil ? DSColor.Status.danger : DSColor.Text.tertiary)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
      }
    }
    .dsAnimation(DSMotion.quick, value: self.effectiveMessage)
  }

  private var effectiveMessage: String? {
    self.errorText ?? self.helperText
  }
}
