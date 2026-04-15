import SwiftUI

/// Vertical stack pre-wired to DS spacing tokens.
///
/// Defaults that encode DS convention:
/// - Alignment: `.leading` (most content is left-aligned)
/// - Spacing: `DSSpacing.md` (16 pt — the standard inter-section gap)
///
/// Override either at the call site when layout intent differs:
/// ```swift
/// DSVStack(alignment: .center, spacing: DSSpacing.sm) {
///   IconBadge()
///   TitleLabel()
/// }
/// ```
public struct DSVStack<Content: View>: View {
  private let alignment: HorizontalAlignment
  private let spacing: CGFloat
  private let content: Content

  public init(
    alignment: HorizontalAlignment = .leading,
    spacing: CGFloat = DSSpacing.md,
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }

  public var body: some View {
    VStack(alignment: self.alignment, spacing: self.spacing) {
      self.content
    }
  }
}

/// Horizontal stack pre-wired to DS spacing tokens.
///
/// Defaults that encode DS convention:
/// - Alignment: `.center` (most inline content should be vertically centred)
/// - Spacing: `DSSpacing.sm` (12 pt — the standard gap between inline elements)
///
/// Override at the call site when needed:
/// ```swift
/// DSHStack(alignment: .top, spacing: DSSpacing.md) {
///   IconView()
///   MultiLineLabel()
/// }
/// ```
public struct DSHStack<Content: View>: View {
  private let alignment: VerticalAlignment
  private let spacing: CGFloat
  private let content: Content

  public init(
    alignment: VerticalAlignment = .center,
    spacing: CGFloat = DSSpacing.sm,
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }

  public var body: some View {
    HStack(alignment: self.alignment, spacing: self.spacing) {
      self.content
    }
  }
}
