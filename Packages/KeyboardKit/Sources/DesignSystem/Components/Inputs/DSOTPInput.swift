import SwiftUI

public struct DSOTPInput: View {
  private let length: Int
  private let onComplete: ((String) -> Void)?
  @Binding private var code: String
  @FocusState private var isFocused: Bool
  @Environment(\.isEnabled) private var isEnabled: Bool

  public init(
    length: Int = 6,
    code: Binding<String>,
    onComplete: ((String) -> Void)? = nil
  ) {
    self.length = length
    self._code = code
    self.onComplete = onComplete
  }

  public var body: some View {
    ZStack {
      TextField("", text: self.$code)
        .keyboardType(.numberPad)
        .textContentType(.oneTimeCode)
        .focused(self.$isFocused)
        .foregroundStyle(Color.clear)
        .accentColor(.clear)
        .onChange(of: self.code) { _, newValue in
          let filtered = newValue.filter(\.isNumber)
          let clipped = String(filtered.prefix(self.length))
          if clipped != self.code {
            self.code = clipped
          }
          if clipped.count == self.length {
            self.onComplete?(clipped)
          }
        }
      HStack(spacing: DSSpacing.xs) {
        ForEach(0..<self.length, id: \.self) { index in
          self.digitBox(for: index)
        }
      }
      .allowsHitTesting(false)
    }
    .contentShape(Rectangle())
    .onTapGesture {
      self.isFocused = true
    }
    .opacity(self.isEnabled ? 1 : 0.5)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Verification code")
    .accessibilityValue(self.code)
  }

  @ViewBuilder
  private func digitBox(for index: Int) -> some View {
    let digit = self.digit(at: index)
    let isActive = self.code.count == index && self.isFocused
    let isFilled = digit != nil
    RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
      .fill(isFilled ? DSColor.Background.surface : DSColor.Background.raised)
      .frame(width: 44, height: 52)
      .overlay(
        RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
          .strokeBorder(
            isActive ? DSColor.Border.focus : DSColor.Border.subtle,
            lineWidth: isActive ? 2 : 1
          )
      )
      .overlay {
        if let digit = digit {
          DSText(String(digit), style: .titleSmall, alignment: .center)
        } else if isActive {
          Rectangle()
            .fill(DSColor.Accent.primary)
            .frame(width: 2, height: 22)
            .opacity(0.8)
        }
      }
      .dsAnimation(DSMotion.snappy, value: self.code)
  }

  private func digit(at index: Int) -> Character? {
    guard index < self.code.count else { return nil }
    return self.code[self.code.index(self.code.startIndex, offsetBy: index)]
  }
}
