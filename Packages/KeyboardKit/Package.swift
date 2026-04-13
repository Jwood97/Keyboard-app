// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "KeyboardKit",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(name: "AppCore", targets: ["AppCore"]),
    .library(name: "DesignSystem", targets: ["DesignSystem"]),
    .library(name: "Persistence", targets: ["Persistence"]),
    .library(name: "ModelCatalog", targets: ["ModelCatalog"]),
    .library(name: "SpeechRecognition", targets: ["SpeechRecognition"]),
    .library(name: "KeyboardUI", targets: ["KeyboardUI"]),
    .library(name: "Onboarding", targets: ["Onboarding"]),
    .library(name: "AppFeature", targets: ["AppFeature"])
  ],
  targets: [
    .target(name: "AppCore", path: "Sources/AppCore"),
    .target(
      name: "DesignSystem",
      dependencies: ["AppCore"],
      path: "Sources/DesignSystem",
      resources: [.process("Resources/Icons.xcassets")]
    ),
    .target(name: "Persistence", dependencies: ["AppCore"], path: "Sources/Persistence"),
    .target(name: "ModelCatalog", dependencies: ["AppCore", "Persistence"], path: "Sources/ModelCatalog"),
    .target(name: "SpeechRecognition", dependencies: ["AppCore", "ModelCatalog"], path: "Sources/SpeechRecognition"),
    .target(
      name: "KeyboardUI",
      dependencies: ["AppCore", "DesignSystem", "Persistence", "SpeechRecognition"],
      path: "Sources/KeyboardUI"
    ),
    .target(
      name: "Onboarding",
      dependencies: ["AppCore", "DesignSystem", "ModelCatalog", "Persistence"],
      path: "Sources/Onboarding"
    ),
    .target(
      name: "AppFeature",
      dependencies: [
        "AppCore",
        "DesignSystem",
        "Persistence",
        "ModelCatalog",
        "SpeechRecognition",
        "KeyboardUI",
        "Onboarding"
      ],
      path: "Sources/AppFeature"
    )
  ]
)
