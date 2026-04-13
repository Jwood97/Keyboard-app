import SwiftUI

public struct DSGallery: View {
  public init() {}

  public var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: DSSpacing.xl) {
          ColorGallery()
          TypographyGallery()
          ButtonGallery()
          InputGallery()
          ContainerGallery()
          FeedbackGallery()
          NavigationGallery()
        }
        .padding(DSSpacing.md)
        .padding(.bottom, DSSpacing.xxl)
      }
      .navigationTitle("Design System")
      .navigationBarTitleDisplayMode(.large)
      .background(DSColor.Background.canvas.ignoresSafeArea())
    }
  }
}

private struct SectionTitle: View {
  let title: String

  var body: some View {
    DSText(title, style: .overline, color: DSColor.Text.secondary)
      .padding(.horizontal, DSSpacing.xxs)
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
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
          DSText("Display XL", style: .displayXL)
          DSText("Display Large", style: .displayLarge)
          DSText("Display", style: .display)
          DSText("Title Large", style: .titleLarge)
          DSText("Title", style: .title)
          DSText("Headline", style: .headline)
          DSText("Body text keeps rhythm at 16pt.", style: .body)
          DSText("Callout emphasises secondary context.", style: .callout)
          DSText("FOOTNOTE / SECONDARY LABELS", style: .overline, color: DSColor.Text.secondary)
        }
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
          DSButton("Primary action", icon: "sparkles", fullWidth: true, action: {})
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
            DSIconButton(icon: "bell.fill", style: .filled, action: {})
            DSIconButton(icon: "heart.fill", style: .soft, action: {})
            DSIconButton(icon: "bookmark", style: .outline, action: {})
            DSIconButton(icon: "ellipsis", style: .ghost, action: {})
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

  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Inputs")
      DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
          DSTextField(
            "you@keyboard.app",
            text: self.$text,
            title: "Email",
            leadingIcon: "envelope",
            helperText: "We'll never share it."
          )
          DSTextField(
            "••••••••",
            text: self.$secure,
            title: "Password",
            leadingIcon: "lock",
            isSecure: true
          )
          DSTextEditor("What did you think?", text: self.$editorText, title: "Feedback", maxLength: 140)
          DSSearchBar(query: self.$query)
          DSSegmentedControl(
            options: [
              .init(id: "models", title: "Models", icon: "brain.head.profile"),
              .init(id: "voice", title: "Voice", icon: "waveform"),
              .init(id: "haptics", title: "Haptics", icon: "hand.tap")
            ],
            selection: self.$segment
          )
          DSSlider("Volume", value: self.$slider)
          DSStepper("Predictions", value: self.$steps, in: 0...10)
          DSToggle(
            "Voice auto-punctuation",
            isOn: self.$toggle,
            subtitle: "Adds periods and commas automatically.",
            icon: "waveform"
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
  var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
      SectionTitle(title: "Cards & Lists")
      DSCard(style: .elevated) {
        HStack(spacing: DSSpacing.md) {
          DSAvatar(.systemIcon("leaf.fill"), size: .lg)
          VStack(alignment: .leading, spacing: 4) {
            DSText("Matcha Blend", style: .titleSmall)
            DSText("On-device. Warm, calm, and clean.", style: .footnote, color: DSColor.Text.secondary)
            HStack {
              DSChip("New", icon: "sparkles", style: .accent)
              DSChip("Beta", style: .warning, size: .small)
            }
          }
        }
      }
      DSSection("Preferences", footer: "Used across the app and keyboard.") {
        DSListRow(
          "Voice typing",
          subtitle: "Parakeet TDT 0.6B",
          icon: "waveform",
          accessory: .chevron,
          action: {}
        )
        DSDivider()
        DSListRow(
          "Haptics",
          subtitle: "Subtle feedback on every key",
          icon: "hand.tap",
          accessory: .info("On"),
          action: {}
        )
        DSDivider()
        DSListRow(
          "Remove keyboard",
          icon: "trash",
          accessory: .none,
          destructive: true,
          action: {}
        )
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
            icon: "tray",
            primaryAction: (label: "Browse models", handler: {})
          )
        }
      }
    }
  }
}

private struct NavigationGallery: View {
  @State private var tab: String = "home"

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
              DSIconButton(icon: "gearshape", style: .ghost, tint: DSColor.Text.primary, action: {})
            }
          )
          Divider().overlay(DSColor.Border.subtle)
          DSTabBar(
            items: [
              .init(id: "home", title: "Home", icon: "house", selectedIcon: "house.fill"),
              .init(id: "models", title: "Models", icon: "brain", selectedIcon: "brain.head.profile", badge: "1"),
              .init(id: "settings", title: "Settings", icon: "gearshape", selectedIcon: "gearshape.fill")
            ],
            selection: self.$tab
          )
        }
      }
    }
  }
}
