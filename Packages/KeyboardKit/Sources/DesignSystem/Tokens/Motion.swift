import SwiftUI

public enum DSMotion {
  public static let instant = Animation.linear(duration: 0.08)
  public static let quick = Animation.easeOut(duration: 0.14)
  public static let standard = Animation.easeInOut(duration: 0.22)
  public static let gentle = Animation.easeOut(duration: 0.32)

  public static let snappy = Animation.spring(response: 0.28, dampingFraction: 0.86, blendDuration: 0)
  public static let refined = Animation.spring(response: 0.36, dampingFraction: 0.9, blendDuration: 0)
  public static let emphasised = Animation.spring(response: 0.44, dampingFraction: 0.82, blendDuration: 0)
  public static let hero = Animation.spring(response: 0.68, dampingFraction: 0.78, blendDuration: 0)
  public static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.65, blendDuration: 0)

  public static let press = Animation.spring(response: 0.22, dampingFraction: 0.78, blendDuration: 0)
  public static let release = Animation.spring(response: 0.34, dampingFraction: 0.86, blendDuration: 0)

  public static let checkIn = Animation.spring(response: 0.32, dampingFraction: 0.62, blendDuration: 0)
  public static let checkOut = Animation.easeOut(duration: 0.14)
  public static let overlay = Animation.spring(response: 0.42, dampingFraction: 0.84, blendDuration: 0)

  public static let pulse = Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)
  public static let shimmer = Animation.linear(duration: 1.4).repeatForever(autoreverses: false)
  public static let spin = Animation.linear(duration: 1.1).repeatForever(autoreverses: false)
  public static let spinSlow = Animation.linear(duration: 2.4).repeatForever(autoreverses: false)
}
