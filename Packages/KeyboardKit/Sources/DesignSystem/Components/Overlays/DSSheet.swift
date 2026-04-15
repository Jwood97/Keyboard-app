import SwiftUI

public enum DSSheetDetent: Sendable {
  case small
  case medium
  case large
  case custom(CGFloat)

  public var heightFraction: CGFloat {
    switch self {
      case .small:
        return 0.32
      case .medium:
        return 0.55
      case .large:
        return 0.88
      case .custom(let value):
        return min(max(value, 0.1), 1.0)
    }
  }
}

public struct DSBottomSheet<Content: View>: View {
  private let title: String?
  private let detent: DSSheetDetent
  private let showsHandle: Bool
  private let showsDismissButton: Bool
  @Binding private var isPresented: Bool
  private let content: Content

  public init(
    title: String? = nil,
    detent: DSSheetDetent = .medium,
    showsHandle: Bool = true,
    showsDismissButton: Bool = false,
    isPresented: Binding<Bool>,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.detent = detent
    self.showsHandle = showsHandle
    self.showsDismissButton = showsDismissButton
    self._isPresented = isPresented
    self.content = content()
  }

  public var body: some View {
    GeometryReader { proxy in
      VStack(spacing: 0) {
        if self.showsHandle {
          Capsule()
            .fill(DSColor.Text.tertiary.opacity(0.4))
            .frame(width: 40, height: 5)
            .padding(.top, DSSpacing.xs)
            .padding(.bottom, self.title == nil ? DSSpacing.sm : DSSpacing.xs)
        }
        if self.title != nil || self.showsDismissButton {
          HStack {
            if let title = self.title {
              DSText(title, style: .titleSmall)
            }
            Spacer()
            if self.showsDismissButton {
              DSIconButton(
                icon: DSIcon.UI.close,
                style: .ghost,
                size: .small,
                tint: DSColor.Text.secondary,
                accessibilityLabel: "Close"
              ) {
                self.isPresented = false
              }
            }
          }
          .padding(.horizontal, DSSpacing.lg)
          .padding(.bottom, DSSpacing.sm)
        }
        ScrollView {
          self.content
            .padding(.horizontal, DSSpacing.lg)
            .padding(.bottom, DSSpacing.xl)
        }
      }
      .frame(maxWidth: .infinity)
      .frame(height: proxy.size.height * self.detent.heightFraction)
      .background(
        UnevenRoundedRectangle(
          topLeadingRadius: DSRadius.sheet,
          topTrailingRadius: DSRadius.sheet,
          style: .continuous
        )
        .fill(DSColor.Background.surface)
      )
      .dsShadow(DSElevation.xl)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
  }
}

public extension View {
  func dsBottomSheet<Content: View>(
    title: String? = nil,
    detent: DSSheetDetent = .medium,
    showsHandle: Bool = true,
    showsDismissButton: Bool = false,
    isPresented: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    self.modifier(DSBottomSheetModifier(
      title: title,
      detent: detent,
      showsHandle: showsHandle,
      showsDismissButton: showsDismissButton,
      isPresented: isPresented,
      sheetContent: content
    ))
  }
}

private struct DSBottomSheetModifier<SheetContent: View>: ViewModifier {
  let title: String?
  let detent: DSSheetDetent
  let showsHandle: Bool
  let showsDismissButton: Bool
  @Binding var isPresented: Bool
  let sheetContent: () -> SheetContent
  @GestureState private var dragOffset: CGFloat = 0

  func body(content: Content) -> some View {
    content.overlay {
      if self.isPresented {
        ZStack(alignment: .bottom) {
          DSColor.Background.overlay
            .ignoresSafeArea()
            .transition(.opacity)
            .onTapGesture {
              self.isPresented = false
            }
          DSBottomSheet(
            title: self.title,
            detent: self.detent,
            showsHandle: self.showsHandle,
            showsDismissButton: self.showsDismissButton,
            isPresented: self.$isPresented,
            content: self.sheetContent
          )
          .offset(y: max(0, self.dragOffset))
          .gesture(
            DragGesture()
              .updating(self.$dragOffset) { value, state, _ in
                state = value.translation.height
              }
              .onEnded { value in
                if value.translation.height > 120 {
                  self.isPresented = false
                }
              }
          )
          .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .ignoresSafeArea(edges: .bottom)
        .zIndex(DSZIndex.sheet)
      }
    }
    .dsAnimation(DSMotion.overlay, value: self.isPresented)
  }
}
