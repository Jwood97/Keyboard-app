import SwiftUI

public enum DSDatePickerMode: Sendable {
  case date
  case time
  case dateAndTime

  var components: DatePicker.Components {
    switch self {
      case .date:
        return [.date]
      case .time:
        return [.hourAndMinute]
      case .dateAndTime:
        return [.date, .hourAndMinute]
    }
  }
}

public struct DSDatePicker: View {
  private let title: String?
  private let mode: DSDatePickerMode
  private let range: ClosedRange<Date>?
  @Binding private var date: Date
  @State private var isPresented: Bool = false
  @Environment(\.isEnabled) private var isEnabled: Bool

  public init(
    _ title: String? = nil,
    date: Binding<Date>,
    mode: DSDatePickerMode = .date,
    in range: ClosedRange<Date>? = nil
  ) {
    self.title = title
    self._date = date
    self.mode = mode
    self.range = range
  }

  public var body: some View {
    Button {
      DSHaptics.selection()
      withAnimation(DSMotion.snappy) {
        self.isPresented.toggle()
      }
    } label: {
      HStack(spacing: DSSpacing.sm) {
        DSIconView(DSIcon.calendar, weight: .regular, size: 18, tint: DSColor.Accent.primary)
        VStack(alignment: .leading, spacing: 2) {
          if let title = self.title {
            DSText(title, style: .caption, color: DSColor.Text.secondary)
          }
          DSText(self.formattedDate, style: .bodyStrong)
        }
        Spacer(minLength: DSSpacing.sm)
        DSIconView(
          DSIcon.UI.chevronDown,
          weight: .regular,
          size: 12,
          tint: DSColor.Text.tertiary
        )
        .rotationEffect(.degrees(self.isPresented ? 180 : 0))
      }
      .padding(.horizontal, DSSpacing.md)
      .padding(.vertical, DSSpacing.sm)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: DSRadius.field, style: .continuous)
          .fill(DSColor.Background.surface)
      )
      .overlay(
        RoundedRectangle(cornerRadius: DSRadius.field, style: .continuous)
          .strokeBorder(DSColor.Border.subtle, lineWidth: 1)
      )
    }
    .buttonStyle(DSPressScaleStyle(pressedScale: 0.99))
    .dsBottomSheet(
      title: self.title,
      detent: .small,
      showsDismissButton: true,
      isPresented: self.$isPresented
    ) {
      Group {
        if let range = self.range {
          DatePicker(
            self.title ?? "Date",
            selection: self.$date,
            in: range,
            displayedComponents: self.mode.components
          )
        } else {
          DatePicker(
            self.title ?? "Date",
            selection: self.$date,
            displayedComponents: self.mode.components
          )
        }
      }
      .datePickerStyle(.graphical)
      .labelsHidden()
    }
    .opacity(self.isEnabled ? 1 : 0.5)
    .disabled(!self.isEnabled)
  }

  private var formattedDate: String {
    let formatter = DateFormatter()
    switch self.mode {
      case .date:
        formatter.dateStyle = .medium
      case .time:
        formatter.timeStyle = .short
      case .dateAndTime:
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
    }
    return formatter.string(from: self.date)
  }
}
