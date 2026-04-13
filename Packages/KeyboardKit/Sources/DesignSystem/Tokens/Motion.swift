import SwiftUI

public enum DSMotion {
  public static let instant = Animation.linear(duration: 0.08)
  public static let quick = Animation.easeOut(duration: 0.16)
  public static let standard = Animation.easeInOut(duration: 0.24)
  public static let gentle = Animation.easeOut(duration: 0.32)
  public static let emphasised = Animation.spring(response: 0.45, dampingFraction: 0.78)
  public static let hero = Animation.spring(response: 0.72, dampingFraction: 0.72)
  public static let bouncy = Animation.spring(response: 0.35, dampingFraction: 0.6)
  public static let press = Animation.spring(response: 0.18, dampingFraction: 0.75)
  public static let release = Animation.spring(response: 0.3, dampingFraction: 0.8)
  public static let pulse = Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)
  public static let shimmer = Animation.linear(duration: 1.4).repeatForever(autoreverses: false)
}
