import SwiftUI
import UIKit

public extension Color {
  static func dynamic(light: Color, dark: Color) -> Color {
    Color(UIColor { traits in
      traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
    })
  }

  init(hex: UInt32, alpha: Double = 1.0) {
    let red = Double((hex >> 16) & 0xFF) / 255.0
    let green = Double((hex >> 8) & 0xFF) / 255.0
    let blue = Double(hex & 0xFF) / 255.0
    self.init(red: red, green: green, blue: blue, opacity: alpha)
  }
}
