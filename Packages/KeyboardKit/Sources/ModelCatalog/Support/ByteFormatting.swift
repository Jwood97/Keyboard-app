import Foundation

public enum ByteFormatting {
  private static let sizeFormatter: ByteCountFormatter = {
    let f = ByteCountFormatter()
    f.allowedUnits = [.useAll]
    f.countStyle = .file
    f.includesUnit = true
    f.isAdaptive = true
    return f
  }()

  public static func human(_ bytes: Int64) -> String {
    sizeFormatter.string(fromByteCount: max(0, bytes))
  }

  public static func humanRate(_ bytesPerSecond: Double) -> String {
    guard bytesPerSecond.isFinite, bytesPerSecond > 0 else { return "–" }
    return human(Int64(bytesPerSecond)) + "/s"
  }

  public static func humanDuration(_ seconds: TimeInterval?) -> String {
    guard let seconds, seconds.isFinite, seconds >= 0 else { return "–" }
    if seconds < 1 { return "< 1s" }
    let total = Int(seconds.rounded())
    let h = total / 3600
    let m = (total % 3600) / 60
    let s = total % 60
    if h > 0 { return "\(h)h \(m)m" }
    if m > 0 { return "\(m)m \(s)s" }
    return "\(s)s"
  }
}
