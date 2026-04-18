import Foundation

public enum ParakeetCatalog {
  public static let mini: ModelSpec = ModelSpec(
    id: "parakeet-tdt-0.6b-v2-int8",
    family: "parakeet",
    displayName: "Parakeet Mini",
    summary: "Fast on-device speech recognition tuned for short utterances and low-latency keyboard use.",
    tier: .mini,
    runtime: .coreML,
    precision: .int8,
    repository: "FluidInference/parakeet-tdt-0.6b-v2-coreml",
    revision: "main",
    artifacts: [
      ModelArtifact(remotePath: "int8/Preprocessor.mlmodelc.zip", expectedByteSize: 3_200_000),
      ModelArtifact(remotePath: "int8/Encoder.mlmodelc.zip", expectedByteSize: 118_000_000),
      ModelArtifact(remotePath: "int8/Decoder.mlmodelc.zip", expectedByteSize: 14_500_000),
      ModelArtifact(remotePath: "int8/Joint.mlmodelc.zip", expectedByteSize: 5_200_000),
      ModelArtifact(remotePath: "tokenizer.json", expectedByteSize: 1_900_000),
      ModelArtifact(remotePath: "config.json", expectedByteSize: 12_000)
    ],
    supportedLocales: ["en-US"],
    license: "CC-BY-4.0",
    minimumOSVersion: "17.0"
  )

  public static let standard: ModelSpec = ModelSpec(
    id: "parakeet-tdt-0.6b-v2-fp16",
    family: "parakeet",
    displayName: "Parakeet Standard",
    summary: "Balanced speech recognition with strong accuracy across everyday dictation.",
    tier: .standard,
    runtime: .coreML,
    precision: .fp16,
    repository: "FluidInference/parakeet-tdt-0.6b-v2-coreml",
    revision: "main",
    artifacts: [
      ModelArtifact(remotePath: "fp16/Preprocessor.mlmodelc.zip", expectedByteSize: 3_400_000),
      ModelArtifact(remotePath: "fp16/Encoder.mlmodelc.zip", expectedByteSize: 468_000_000),
      ModelArtifact(remotePath: "fp16/Decoder.mlmodelc.zip", expectedByteSize: 58_000_000),
      ModelArtifact(remotePath: "fp16/Joint.mlmodelc.zip", expectedByteSize: 21_000_000),
      ModelArtifact(remotePath: "tokenizer.json", expectedByteSize: 1_900_000),
      ModelArtifact(remotePath: "config.json", expectedByteSize: 12_000)
    ],
    supportedLocales: ["en-US"],
    license: "CC-BY-4.0",
    minimumOSVersion: "17.0"
  )

  public static let pro: ModelSpec = ModelSpec(
    id: "parakeet-tdt-1.1b-fp16",
    family: "parakeet",
    displayName: "Parakeet Pro",
    summary: "Largest Parakeet variant. Highest accuracy for complex audio and long-form dictation.",
    tier: .pro,
    runtime: .coreML,
    precision: .fp16,
    repository: "FluidInference/parakeet-tdt-1.1b-coreml",
    revision: "main",
    artifacts: [
      ModelArtifact(remotePath: "fp16/Preprocessor.mlmodelc.zip", expectedByteSize: 3_400_000),
      ModelArtifact(remotePath: "fp16/Encoder.mlmodelc.zip", expectedByteSize: 902_000_000),
      ModelArtifact(remotePath: "fp16/Decoder.mlmodelc.zip", expectedByteSize: 110_000_000),
      ModelArtifact(remotePath: "fp16/Joint.mlmodelc.zip", expectedByteSize: 42_000_000),
      ModelArtifact(remotePath: "tokenizer.json", expectedByteSize: 1_900_000),
      ModelArtifact(remotePath: "config.json", expectedByteSize: 12_000)
    ],
    supportedLocales: ["en-US"],
    license: "CC-BY-4.0",
    minimumOSVersion: "17.0"
  )

  public static let all: [ModelSpec] = [mini, standard, pro]

  public static func spec(for tier: ModelTier) -> ModelSpec {
    switch tier {
      case .mini: return mini
      case .standard: return standard
      case .pro: return pro
    }
  }

  public static func spec(for id: ModelIdentifier) -> ModelSpec? {
    all.first { $0.id == id }
  }

  public static var defaultRecommended: ModelSpec { standard }
}
