import Foundation

public enum ModelCatalog {
  public static var allSpecs: [ModelSpec] { ParakeetCatalog.all }

  public static func spec(for tier: ModelTier) -> ModelSpec {
    ParakeetCatalog.spec(for: tier)
  }

  public static func spec(for id: ModelIdentifier) -> ModelSpec? {
    ParakeetCatalog.spec(for: id)
  }

  public static var recommended: ModelSpec { ParakeetCatalog.defaultRecommended }

  public static func makeManager(
    storage: ModelStorage.Configuration,
    endpoint: HuggingFaceEndpoint = HuggingFaceEndpoint(),
    configuration: ModelDownloadManager.Configuration = .default
  ) -> ModelDownloadManager {
    let storageInstance = ModelStorage(configuration: storage)
    try? storageInstance.prepare()
    let store = InstallationStore.default(in: storage.rootDirectory)
    return ModelDownloadManager(
      storage: storageInstance,
      installations: store,
      endpoint: endpoint,
      configuration: configuration
    )
  }
}
