import SwiftUI

public struct DSGallery: View {
  @State private var filter: GalleryFilter = .core
  private let topAnchor = "gallery-top"

  public init() {}

  private var visibleSections: [GallerySection] {
    GallerySection.allCases.filter { $0.filter == self.filter }
  }

  public var body: some View {
    NavigationStack {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: DSSpacing.xl) {
            Color.clear
              .frame(height: 1)
              .id(self.topAnchor)
            GallerySummary(filter: self.filter, sectionCount: self.visibleSections.count)
            ForEach(self.visibleSections) { section in
              self.sectionView(section)
            }
          }
          .padding(DSSpacing.md)
          .padding(.bottom, DSSpacing.xxxl)
        }
        .scrollIndicators(.hidden)
        .background(DSColor.Background.canvas.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
          self.filterBar
        }
        .onChange(of: self.filter) { _, _ in
          withAnimation(DSMotion.refined) {
            proxy.scrollTo(self.topAnchor, anchor: .top)
          }
        }
      }
      .navigationTitle("Design System")
      .navigationBarTitleDisplayMode(.large)
    }
  }

  @ViewBuilder
  private func sectionView(_ section: GallerySection) -> some View {
    switch section {
      case .colors:
        ColorGallery()
      case .typography:
        TypographyGallery()
      case .icons:
        IconGallery()
      case .buttons:
        ButtonGallery()
      case .containers:
        ContainerGallery()
      case .layout:
        LayoutGallery()
      case .display:
        DisplayGallery()
      case .inputs:
        InputGallery()
      case .advancedInputs:
        AdvancedInputGallery()
      case .formFields:
        FormFieldGallery()
      case .feedback:
        FeedbackGallery()
      case .spinners:
        SpinnerGallery()
      case .overlays:
        OverlaysGallery()
      case .navigation:
        NavigationGallery()
    }
  }

  private var filterBar: some View {
    VStack(spacing: 0) {
      DSSegmentedControl(
        options: GalleryFilter.allCases.map { .init(id: $0, title: $0.segmentTitle) },
        selection: self.$filter
      )
      .padding(.horizontal, DSSpacing.md)
      .padding(.vertical, DSSpacing.sm)

      Rectangle()
        .fill(DSColor.Border.subtle)
        .frame(height: 1)
    }
    .background(DSColor.Background.canvas.opacity(0.98))
  }
}

private struct SectionTitle: View {
  let title: String
  let subtitle: String?

  init(title: String, subtitle: String? = nil) {
    self.title = title
    self.subtitle = subtitle
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      DSText(self.title, style: .titleSmall)
      if let subtitle = self.subtitle {
        DSText(subtitle, style: .caption, color: DSColor.Text.secondary)
      }
    }
    .padding(.horizontal, DSSpacing.xxs)
  }
}

private enum GalleryFilter: String, CaseIterable, Hashable, Identifiable {
  case core
  case inputs
  case feedback
  case navigation

  var id: String { self.rawValue }

  var title: String {
    switch self {
      case .core:
        return "Core"
      case .inputs:
        return "Inputs"
      case .feedback:
        return "Feedback"
      case .navigation:
        return "Navigation"
    }
  }

  var segmentTitle: String {
    switch self {
      case .navigation:
        return "Nav"
      default:
        return self.title
    }
  }

  var subtitle: String {
    switch self {
      case .core:
        return "Foundations, layout, and display patterns."
      case .inputs:
        return "Forms, editing, and selection controls."
      case .feedback:
        return "Status, progress, empty states, and overlays."
      case .navigation:
        return "Movement, tabs, breadcrumbs, and page structure."
    }
  }

  var icon: DSIcon {
    switch self {
      case .core:
        return .sparkle
      case .inputs:
        return .waveform
      case .feedback:
        return .bell
      case .navigation:
        return .compass
    }
  }
}

private enum GallerySection: String, CaseIterable, Identifiable {
  case colors
  case typography
  case icons
  case buttons
  case containers
  case layout
  case display
  case inputs
  case advancedInputs
  case formFields
  case feedback
  case spinners
  case overlays
  case navigation

  var id: String { self.rawValue }

  var filter: GalleryFilter {
    switch self {
      case .colors, .typography, .icons, .buttons, .containers, .layout, .display:
        return .core
      case .inputs, .advancedInputs, .formFields:
        return .inputs
      case .feedback, .spinners, .overlays:
        return .feedback
      case .navigation:
        return .navigation
    }
  }
}

private struct GallerySummary: View {
  let filter: GalleryFilter
  let sectionCount: Int

  var body: some View {
    DSCard(style: .plain, padding: DSSpacing.lg, radius: DSRadius.lg) {
      HStack(alignment: .top, spacing: DSSpacing.md) {
        DSIconBadge(self.filter.icon, style: .accent, size: .medium)
        VStack(alignment: .leading, spacing: 4) {
          DSText(self.filter.title, style: .titleSmall)
          DSText(self.filter.subtitle, style: .footnote, color: DSColor.Text.secondary)
        }
        Spacer(minLength: DSSpacing.sm)
        DSText("\(self.sectionCount) sections", style: .caption, color: DSColor.Text.tertiary)
      }
    }
  }
}

private struct ColorGallery: View {
  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Colors")
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
          ramp("Matcha", colors: [
            ("50", Palette.Matcha.shade50),
            ("200", Palette.Matcha.shade200),
            ("400", Palette.Matcha.shade400),
            ("500", Palette.Matcha.shade500),
            ("700", Palette.Matcha.shade700),
            ("900", Palette.Matcha.shade900)
          ])
          ramp("Sand", colors: [
            ("50", Palette.Sand.shade50),
            ("200", Palette.Sand.shade200),
            ("400", Palette.Sand.shade400),
            ("600", Palette.Sand.shade600),
            ("800", Palette.Sand.shade800),
            ("950", Palette.Sand.shade950)
          ])
          ramp("Peach", colors: [
            ("50", Palette.Peach.shade50),
            ("200", Palette.Peach.shade200),
            ("400", Palette.Peach.shade400),
            ("600", Palette.Peach.shade600)
          ])
          ramp("Signal", colors: [
            ("success", Palette.Signal.success),
            ("warning", Palette.Signal.warning),
            ("danger", Palette.Signal.danger),
            ("info", Palette.Signal.info)
          ])
        }
      }
    }
  }

  @ViewBuilder
  private func ramp(_ name: String, colors: [(String, Color)]) -> some View {
    VStack(alignment: .leading, spacing: DSSpacing.xs) {
      DSText(name, style: .captionStrong, color: DSColor.Text.secondary)
      HStack(spacing: 6) {
        ForEach(Array(colors.enumerated()), id: \.offset) { _, item in
          VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
              .fill(item.1)
              .frame(height: 40)
              .overlay(
                RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
                  .strokeBorder(DSColor.Border.subtle, lineWidth: 1)
              )
            DSText(item.0, style: .caption, color: DSColor.Text.tertiary)
          }
          .frame(maxWidth: .infinity)
        }
      }
    }
  }
}

private struct TypographyGallery: View {
  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Typography")
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
          VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText("Aa", style: .displayXL)
            DSText("Fraunces — warm editorial serif", style: .captionStrong, color: DSColor.Text.secondary)
          }
          DSDivider()
          VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText("Display XL", style: .displayXL)
            DSText("Display Large", style: .displayLarge)
            DSText("Display", style: .display)
          }
          DSDivider()
          VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText("Title Large", style: .titleLarge)
            DSText("Title", style: .title)
            DSText("Title Small", style: .titleSmall)
            DSText("Headline", style: .headline)
            DSText("Inter Display / Inter — precise, readable UI", style: .caption, color: DSColor.Text.tertiary)
          }
          DSDivider()
          VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText("Body text keeps rhythm at 16pt and flows cleanly across long lines.", style: .body)
            DSText("Body strong for emphasis in copy.", style: .bodyStrong)
            DSText("Callout emphasises secondary context.", style: .callout)
            DSText("Subhead — slightly tighter metadata.", style: .subhead, color: DSColor.Text.secondary)
            DSText("Footnote — fine print and helpers.", style: .footnote, color: DSColor.Text.secondary)
            DSText("Caption — 12pt auxiliary labels.", style: .caption, color: DSColor.Text.tertiary)
            DSText("FOOTNOTE / SECONDARY LABELS", style: .overline, color: DSColor.Text.secondary)
          }
          DSDivider()
          VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText("\u{201C}On-device intelligence that feels calm, focused, and warm.\u{201D}", style: .quote, color: DSColor.Text.secondary)
            DSText("Fraunces 9pt — soft text serif for pull quotes", style: .caption, color: DSColor.Text.tertiary)
          }
          DSDivider()
          VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText("let model = Parakeet.load()", style: .mono)
            DSText("retention = 0.94", style: .monoStrong)
            DSText("JetBrains Mono — precision monospace", style: .caption, color: DSColor.Text.tertiary)
          }
        }
      }
    }
  }
}

private struct SpinnerGallery: View {
  private let columns = [GridItem(.adaptive(minimum: 88), spacing: DSSpacing.md)]

  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Spinners")
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
          LazyVGrid(columns: self.columns, alignment: .leading, spacing: DSSpacing.md) {
            self.spinner(label: "Gradient", style: .gradient)
            self.spinner(label: "Arc", style: .arc)
            self.spinner(label: "Dual ring", style: .dualRing)
            self.spinner(label: "Pulse", style: .pulse)
            self.spinner(label: "Dots", style: .dots)
          }
          DSText("DSSpinner ships in 5 variants and 4 sizes.", style: .caption, color: DSColor.Text.tertiary)
          LazyVGrid(columns: self.columns, alignment: .leading, spacing: DSSpacing.md) {
            VStack(spacing: 6) {
              DSSpinner(style: .gradient, size: .small)
              DSText("S", style: .caption, color: DSColor.Text.tertiary)
            }
            VStack(spacing: 6) {
              DSSpinner(style: .gradient, size: .medium)
              DSText("M", style: .caption, color: DSColor.Text.tertiary)
            }
            VStack(spacing: 6) {
              DSSpinner(style: .gradient, size: .large)
              DSText("L", style: .caption, color: DSColor.Text.tertiary)
            }
            VStack(spacing: 6) {
              DSSpinner(style: .gradient, size: .custom(56))
              DSText("XL", style: .caption, color: DSColor.Text.tertiary)
            }
          }
        }
      }
    }
  }

  private func spinner(label: String, style: DSSpinnerStyle) -> some View {
    VStack(spacing: 6) {
      DSSpinner(style: style, size: .medium)
        .frame(height: 28)
      DSText(label, style: .caption, color: DSColor.Text.tertiary)
    }
    .frame(maxWidth: .infinity)
  }
}

private struct IconGallery: View {
  private let preview: [DSIcon] = [
    .leaf, .sparkle, .waveform, .microphone, .brain,
    .gear, .house, .heart, .bookmark, .trash,
    .magnifyingGlass, .bell, .star, .lightning, .cloud,
    .moon, .sun, .palette, .pencilSimple, .chatCircle
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Icons (Phosphor)")
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
          DSText("Regular weight", style: .captionStrong, color: DSColor.Text.secondary)
          self.grid(weight: .regular)
          DSText("Fill weight", style: .captionStrong, color: DSColor.Text.secondary)
          self.grid(weight: .fill)
          DSText("\(DSIcon.all.count) icons available — typed via DSIcon static members.", style: .caption, color: DSColor.Text.tertiary)
        }
      }
    }
  }

  private func grid(weight: DSIconWeight) -> some View {
    let columns = [GridItem(.adaptive(minimum: 76, maximum: 100), spacing: DSSpacing.sm)]
    return LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
      ForEach(self.preview) { icon in
        VStack(spacing: DSSpacing.xs) {
          DSIconBadge(icon, weight: weight, style: .neutral, size: .medium, tint: DSColor.Accent.primary)
          DSText(icon.rawName, style: .caption, color: DSColor.Text.tertiary, alignment: .center)
            .lineLimit(2)
            .frame(height: 28, alignment: .top)
        }
        .frame(maxWidth: .infinity)
        .padding(DSSpacing.sm)
        .background(
          RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
            .fill(DSColor.Background.surface)
        )
        .overlay(
          RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
            .strokeBorder(DSColor.Border.subtle, lineWidth: 1)
        )
      }
    }
  }
}

private struct ButtonGallery: View {
  @State private var loading = false

  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Buttons")
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
          DSButton("Primary action", icon: .sparkle, fullWidth: true, action: {})
          DSButton("Secondary", variant: .secondary, fullWidth: true, action: {})
          DSButton("Tertiary", variant: .tertiary, fullWidth: true, action: {})
          DSButton("Ghost", variant: .ghost, fullWidth: true, action: {})
          DSButton("Destructive", variant: .destructive, fullWidth: true, action: {})
          HStack(spacing: DSSpacing.xs) {
            DSButton("Small", size: .small, action: {})
            DSButton("Medium", size: .medium, action: {})
            DSButton("Large", size: .large, action: {})
          }
          HStack(spacing: DSSpacing.xs) {
            DSButton("Loading", isLoading: self.loading, action: {
              self.loading.toggle()
            })
            DSIconButton(icon: .bell, weight: .fill, style: .filled, action: {})
            DSIconButton(icon: .heart, weight: .fill, style: .soft, action: {})
            DSIconButton(icon: .bookmark, style: .outline, action: {})
            DSIconButton(icon: .dotsThree, style: .ghost, action: {})
          }
        }
      }
    }
  }
}

private struct InputGallery: View {
  @State private var text = ""
  @State private var secure = ""
  @State private var editorText = "Try multiline input here."
  @State private var toggle = true
  @State private var notifications = true
  @State private var checked = true
  @State private var radio: String = "english"
  @State private var segment: String = "models"
  @State private var slider: Double = 0.65
  @State private var steps: Int = 3
  @State private var query = ""
  @State private var disabledText = "Read-only value"

  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Inputs")
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
          DSTextField(
            "you@keyboard.app",
            text: self.$text,
            title: "Email",
            leadingIcon: .envelope,
            helperText: "We'll never share it.",
            validation: .all([.required(), .email()]),
            keyboardType: .emailAddress,
            autocapitalization: .never,
            autocorrectionDisabled: true,
            textContentType: .emailAddress
          )
          DSTextField(
            "••••••••",
            text: self.$secure,
            title: "Password",
            leadingIcon: .lock,
            helperText: "At least 8 characters.",
            validation: .all([.required(), .minLength(8)]),
            isSecure: true,
            autocapitalization: .never,
            autocorrectionDisabled: true,
            textContentType: .newPassword
          )
          DSTextField(
            "Disabled input",
            text: self.$disabledText,
            title: "Locked",
            leadingIcon: .lock
          )
          .disabled(true)
          DSTextEditor(
            "What did you think?",
            text: self.$editorText,
            title: "Feedback",
            maxLength: 140,
            validation: .minLength(10, message: "Tell us a bit more.")
          )
          DSSearchBar(query: self.$query)
          DSSegmentedControl(
            options: [
              .init(id: "models", title: "Models", icon: .brain),
              .init(id: "voice", title: "Voice", icon: .waveform),
              .init(id: "haptics", title: "Haptics", icon: .handTap)
            ],
            selection: self.$segment
          )
          DSSlider("Volume", value: self.$slider)
          DSStepper("Predictions", value: self.$steps, in: 0...10)
          DSToggle(
            "Voice auto-punctuation",
            isOn: self.$toggle,
            subtitle: "Adds periods and commas automatically.",
            icon: .waveform
          )
          HStack(spacing: DSSpacing.lg) {
            DSCheckbox("Launch sound", isChecked: self.$checked)
            DSRadio("English", value: "english", selection: self.$radio)
            DSRadio("Spanish", value: "spanish", selection: self.$radio)
          }
        }
      }
    }
  }
}

private struct ContainerGallery: View {
  private struct ModelItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: DSIcon
  }

  private let models: [ModelItem] = [
    ModelItem(title: "Parakeet TDT 0.6B", subtitle: "140 MB · On-device", icon: .brain),
    ModelItem(title: "Parakeet TDT 1.1B", subtitle: "250 MB · On-device", icon: .brain),
    ModelItem(title: "Whisper Tiny", subtitle: "38 MB · Legacy", icon: .waveform),
    ModelItem(title: "Custom model", subtitle: "Not installed", icon: .plus)
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Cards & Lists")
      DSCard(style: .elevated, action: {}) {
        HStack(spacing: DSSpacing.md) {
          DSIconBadge(.leaf, weight: .fill, style: .accent, size: .large)
          VStack(alignment: .leading, spacing: 4) {
            DSText("Matcha Blend", style: .titleSmall)
            DSText("On-device. Warm, calm, and clean.", style: .footnote, color: DSColor.Text.secondary)
            HStack {
              DSChip("New", icon: .sparkle, style: .accent)
              DSChip("Beta", style: .warning, size: .small)
            }
          }
          Spacer(minLength: 0)
          DSIconView(DSIcon.UI.chevronRight, weight: .regular, size: 14, tint: DSColor.Text.tertiary)
        }
      }
      DSSection("Preferences", footer: "Used across the app and keyboard.") {
        DSListRow(
          "Voice typing",
          subtitle: "Parakeet TDT 0.6B",
          icon: .waveform,
          accessory: .chevron,
          action: {}
        )
        DSDivider()
        DSListRow(
          "Haptics",
          subtitle: "Subtle feedback on every key",
          icon: .handTap,
          accessory: .info("On"),
          action: {}
        )
        DSDivider()
        DSListRow(
          "Remove keyboard",
          icon: .trash,
          accessory: .none,
          destructive: true,
          action: {}
        )
      }
      DSSection("DSList", footer: "Backed by UICollectionView. Best for 20+ items, swipe-to-delete, and reordering.") {
        ForEach(self.models) { item in
          DSListRow(
            item.title,
            subtitle: item.subtitle,
            icon: item.icon,
            accessory: .chevron,
            action: {}
          )
          DSDivider()
        }
      }
    }
  }
}

private struct FeedbackGallery: View {
  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Feedback")
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
          DSProgressBar(value: 0.72, label: "Downloading model")
          DSProgressBar(value: 0, style: .indeterminate, label: "Preparing")
          HStack(spacing: DSSpacing.md) {
            DSProgressRing(value: 0.66)
            DSSpinner(size: 32)
            DSBadge("12", style: .accent, filled: true)
            DSBadge("Pro", style: .success)
            DSBadge("!", style: .danger, filled: true)
          }
          DSInlineMessage(
            "On-device only",
            description: "Your audio never leaves this device.",
            kind: .success,
            primaryAction: (label: "Learn more", handler: {})
          )
          DSInlineMessage(
            "Needs more storage",
            description: "Free up 620 MB to install the Parakeet model.",
            kind: .warning
          )
          DSEmptyState(
            title: "No models yet",
            message: "Download a Parakeet model to start voice typing.",
            icon: .tray,
            primaryAction: (label: "Browse models", handler: {})
          )
        }
      }
    }
  }
}

private struct NavigationGallery: View {
  @State private var tab: String = "home"
  @State private var page: Int = 1

  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Navigation")
      DSCard(padding: DSSpacing.none) {
        VStack(spacing: 0) {
          DSNavigationBar(
            title: "Keyboard",
            subtitle: "Matcha edition",
            largeTitle: true,
            leading: {
              DSBackButton(action: {})
            },
            trailing: {
              DSIconButton(icon: .gear, style: .ghost, tint: DSColor.Text.primary, accessibilityLabel: "Settings", action: {})
            }
          )
          Divider().overlay(DSColor.Border.subtle)
          DSTabBar(
            items: [
              .init(id: "home", title: "Home", icon: .house),
              .init(id: "models", title: "Models", icon: .brain, badge: "1"),
              .init(id: "settings", title: "Settings", icon: .gear)
            ],
            selection: self.$tab
          )
        }
      }
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
          DSText("Breadcrumbs", style: .captionStrong, color: DSColor.Text.secondary)
          DSBreadcrumbs(items: [
            DSBreadcrumb("Settings", handler: {}),
            DSBreadcrumb("Keyboards", handler: {}),
            DSBreadcrumb("Voice")
          ])
          DSDivider(insets: EdgeInsets())
          DSText("Page control", style: .captionStrong, color: DSColor.Text.secondary)
          VStack(spacing: DSSpacing.sm) {
            DSPageControl(total: 5, current: self.page, style: .dots)
            DSPageControl(total: 5, current: self.page, style: .bars)
            DSPageControl(total: 5, current: self.page, style: .numeric)
          }
          HStack {
            DSButton("Prev", variant: .tertiary, size: .small) {
              self.page = max(0, self.page - 1)
            }
            DSButton("Next", variant: .tertiary, size: .small) {
              self.page = min(4, self.page + 1)
            }
          }
        }
      }
    }
  }
}

private struct AdvancedInputGallery: View {
  @State private var otp: String = ""
  @State private var tags: [String] = ["swiftui", "design"]
  @State private var date: Date = Date()

  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Advanced inputs")
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
          VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText("Verification code", style: .captionStrong, color: DSColor.Text.secondary)
            DSOTPInput(length: 6, code: self.$otp)
          }
          VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText("Tags", style: .captionStrong, color: DSColor.Text.secondary)
            DSTagInput("Add a tag", tags: self.$tags)
          }
          DSDatePicker("Meeting date", date: self.$date, mode: .dateAndTime)
        }
      }
    }
  }
}

private struct FormFieldGallery: View {
  @State private var username: String = ""

  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Form fields")
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
          DSFormField(
            "Username",
            helperText: "Letters, numbers, and underscores only.",
            isRequired: true
          ) {
            DSTextField("handle", text: self.$username, leadingIcon: .at)
          }
          DSFormField(
            "Bio",
            errorText: "Bio can't exceed 160 characters.",
            trailingAccessory: {
              DSText("0/160", style: .caption, color: DSColor.Text.tertiary)
            }
          ) {
            DSTextField("Tell people about yourself", text: .constant(""))
          }
        }
      }
    }
  }
}

private struct LayoutGallery: View {
  @State private var expanded: Bool = true
  private let filterChips: [String] = [
    "On-device", "Parakeet", "English", "Low-latency",
    "Punctuation", "Custom vocab", "Streaming", "Offline"
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Layout")
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
          DSText("Flow layout (wraps)", style: .captionStrong, color: DSColor.Text.secondary)
          DSFlowLayout {
            ForEach(self.filterChips, id: \.self) { label in
              DSChip(label, style: .accent, size: .small)
            }
          }
          DSDivider(insets: EdgeInsets())
          DSText("Disclosure / accordion", style: .captionStrong, color: DSColor.Text.secondary)
          DSDisclosure(
            "Voice typing advanced",
            subtitle: "Customise model + language",
            icon: .waveform,
            isExpanded: self.$expanded
          ) {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
              DSKeyValueRow("Model", value: "Parakeet TDT 0.6B", icon: .brain)
              DSKeyValueRow("Language", value: "English", icon: .globe)
              DSKeyValueRow("Latency", value: "~120ms", icon: .lightning, copyable: true)
            }
          }
          DSDivider(insets: EdgeInsets())
          DSText("Stacks", style: .captionStrong, color: DSColor.Text.secondary)
          DSVStack {
            DSChip("DSVStack — leading", style: .soft, size: .small)
            DSChip("spacing: DSSpacing.md", style: .soft, size: .small)
            DSChip("alignment: .leading", style: .soft, size: .small)
          }
          DSHStack {
            DSChip("DSHStack", style: .accent, size: .small)
            DSChip("spacing .sm", style: .accent, size: .small)
            DSChip("center", style: .accent, size: .small)
            Spacer(minLength: 0)
          }
        }
      }
    }
  }
}

private struct DisplayGallery: View {
  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Display")
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
          HStack(spacing: DSSpacing.sm) {
            DSStatCard(
              title: "Daily words",
              value: "1,284",
              subtitle: "vs yesterday",
              icon: .chartLineUp,
              trend: .up("+12%")
            )
            DSStatCard(
              title: "Voice minutes",
              value: "32m",
              subtitle: "today",
              icon: .waveform,
              tint: DSColor.Accent.secondary,
              trend: .down("-4%")
            )
          }
          DSLink("Read the privacy policy", icon: .shieldCheck, trailingIcon: .arrowUpRight)
          DSDivider(insets: EdgeInsets())
          DSText("Images", style: .captionStrong, color: DSColor.Text.secondary)
          HStack(spacing: DSSpacing.sm) {
            DSImage(.icon(.waveform, .fill), aspect: .square, cornerRadius: DSRadius.sm)
              .frame(width: 76, height: 76)
            DSImage(.icon(.brain, .fill), aspect: .square, cornerRadius: DSRadius.sm)
              .frame(width: 76, height: 76)
            DSImage(.icon(.microphone, .fill), aspect: .square, cornerRadius: DSRadius.sm)
              .frame(width: 76, height: 76)
            DSImage(.url(nil), aspect: .square, cornerRadius: DSRadius.sm, placeholderText: "No image")
              .frame(width: 76, height: 76)
          }
          DSDivider(insets: EdgeInsets())
          DSText("Timeline", style: .captionStrong, color: DSColor.Text.secondary)
          DSTimeline(events: [
            DSTimelineEvent(title: "Model downloaded", subtitle: "Parakeet 0.6B", timestamp: "09:32", icon: .download, tint: DSColor.Status.success),
            DSTimelineEvent(title: "First transcription", timestamp: "09:41", icon: .sparkle),
            DSTimelineEvent(title: "Custom vocabulary synced", timestamp: "10:02", icon: .bookmark, tint: DSColor.Accent.secondary)
          ])
        }
      }
    }
  }
}

private struct OverlaysGallery: View {
  @State private var alertShown = false
  @State private var sheetShown = false
  @State private var actionSheetShown = false
  @State private var popoverShown = false
  private let steps: [DSStep] = [
    DSStep(id: 0, title: "Welcome"),
    DSStep(id: 1, title: "Enable"),
    DSStep(id: 2, title: "Model"),
    DSStep(id: 3, title: "Done")
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Overlays & flows")
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
          DSStepIndicator(steps: self.steps, currentStep: 2)
          DSBanner(
            "Storage almost full",
            message: "Free up space before downloading another model.",
            kind: .warning,
            primaryAction: (label: "Manage", handler: {}),
            onDismiss: {}
          )
          HStack(spacing: DSSpacing.xs) {
            DSButton("Show alert", variant: .secondary, size: .small) {
              self.alertShown = true
            }
            DSButton("Bottom sheet", variant: .secondary, size: .small) {
              self.sheetShown = true
            }
            DSButton("Action sheet", variant: .secondary, size: .small) {
              self.actionSheetShown = true
            }
          }
          DSText("Popover / Tooltip", style: .captionStrong, color: DSColor.Text.secondary)
          DSButton("Show popover", variant: .tertiary, size: .small, action: { self.popoverShown.toggle() })
            .dsPopover(isPresented: self.$popoverShown, direction: .bottom) {
              DSTooltip("On-device · No internet required")
            }
          DSDivider(insets: EdgeInsets())
          DSMenu(items: [
            DSMenuItem("Edit", icon: DSIcon.UI.edit, shortcut: "⌘E") {},
            DSMenuItem("Duplicate", icon: DSIcon.UI.copy) {},
            DSMenuItem("Share", icon: DSIcon.UI.share) {},
            DSMenuItem("Delete", icon: DSIcon.UI.trash, role: .destructive) {}
          ]) {
            DSButton("Open menu", icon: DSIcon.UI.more, variant: .tertiary, size: .small, action: {})
          }
        }
      }
    }
    .dsAlert(
      "Delete keyboard?",
      message: "Your custom vocabulary will also be removed.",
      kind: .warning,
      isPresented: self.$alertShown,
      actions: [
        DSAlertAction.destructive("Delete", handler: {}),
        DSAlertAction.cancel()
      ]
    )
    .dsBottomSheet(
      title: "Choose a model",
      detent: .medium,
      showsDismissButton: true,
      isPresented: self.$sheetShown
    ) {
      VStack(alignment: .leading, spacing: DSSpacing.sm) {
        DSListRow("Parakeet TDT 0.6B", subtitle: "Fastest, on-device", icon: .brain, action: {})
        DSListRow("Parakeet TDT 1.1B", subtitle: "Balanced", icon: .brain, action: {})
        DSListRow("Whisper Tiny", subtitle: "Legacy fallback", icon: .brain, action: {})
      }
    }
    .dsActionSheet(
      title: "Edit entry",
      items: [
        DSActionSheetItem("Edit", icon: DSIcon.UI.edit, handler: {}),
        DSActionSheetItem("Duplicate", icon: DSIcon.UI.copy, handler: {}),
        DSActionSheetItem("Delete", icon: DSIcon.UI.trash, role: .destructive, handler: {})
      ],
      isPresented: self.$actionSheetShown
    )
  }
}
