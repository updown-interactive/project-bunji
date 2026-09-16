/// Central configuration for Bunji AI Model Catalog locations and policies.
class BunjiCatalogConfig {
  /// GitHub Raw URL for the remote catalog JSON.
  static const remoteUrl =
      'https://raw.githubusercontent.com/updown-interactive/project-bunji/main/assets/bunji_models.json';

  /// Local bundled asset fallback path.
  static const assetPath = 'assets/bunji_models.json';

  /// Minimum duration between automatic background catalog refreshes.
  static const Duration refreshInterval = Duration(hours: 12);

  /// Default timeout for catalog network requests.
  static const Duration networkTimeout = Duration(seconds: 15);
}
