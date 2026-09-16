import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../config/bunji_catalog_config.dart';
import '../models/bunji_model.dart';

/// Contract for accessing the Bunji AI model catalog.
abstract interface class BunjiModelCatalog {
  /// Loads the catalog following the loading priority:
  /// 1. Valid cached remote catalog
  /// 2. Fresh remote catalog (if available/applicable)
  /// 3. Bundled fallback catalog (`assets/bunji_models.json`)
  Future<ModelCatalog> load();

  /// Refreshes the catalog from the remote repository.
  /// If [force] is false, throttles according to [BunjiCatalogConfig.refreshInterval].
  Future<ModelCatalog> refresh({bool force = false});

  /// The currently active catalog instance in memory, if loaded.
  ModelCatalog? get current;

  /// Whether the currently active catalog was sourced from remote (or valid remote cache).
  bool get isUsingRemoteCatalog;

  /// Metadata describing the currently active catalog source and version.
  CatalogCacheMetadata? get cacheMetadata;

  /// Timestamp of the last attempted or successful refresh.
  DateTime? get lastRefreshTime;

  /// Removes the local disk cache of the remote catalog.
  Future<void> clearCache();

  /// Forces reloading the bundled catalog from app assets.
  Future<ModelCatalog> loadBundledCatalog();
}

/// Production implementation of [BunjiModelCatalog].
class BunjiModelCatalogManager implements BunjiModelCatalog {
  final http.Client? httpClient;
  final AssetBundle? assetBundle;
  final Directory? cacheDirectoryOverride;

  ModelCatalog? _currentCatalog;
  CatalogCacheMetadata? _currentMetadata;
  DateTime? _lastRefreshTime;
  bool _isUsingRemote = false;

  BunjiModelCatalogManager({
    this.httpClient,
    this.assetBundle,
    this.cacheDirectoryOverride,
  });

  http.Client get _client => httpClient ?? http.Client();
  AssetBundle get _bundle => assetBundle ?? rootBundle;

  @override
  ModelCatalog? get current => _currentCatalog;

  @override
  bool get isUsingRemoteCatalog => _isUsingRemote;

  @override
  CatalogCacheMetadata? get cacheMetadata => _currentMetadata;

  @override
  DateTime? get lastRefreshTime => _lastRefreshTime;

  /// Returns `<AppDocuments>/catalog/` directory for storing cached JSON & metadata.
  Future<Directory> _getCatalogDirectory() async {
    final overrideDir = cacheDirectoryOverride;
    if (overrideDir != null) {
      if (!await overrideDir.exists()) {
        await overrideDir.create(recursive: true);
      }
      return overrideDir;
    }
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'catalog'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _getCachedCatalogFile() async {
    final dir = await _getCatalogDirectory();
    return File(p.join(dir.path, 'bunji_models.json'));
  }

  Future<File> _getMetadataFile() async {
    final dir = await _getCatalogDirectory();
    return File(p.join(dir.path, 'metadata.json'));
  }

  @override
  Future<ModelCatalog> load() async {
    // 1. Try loading valid cached remote catalog
    final cached = await _loadCachedCatalog();
    if (cached != null) {
      _currentCatalog = cached;
      _isUsingRemote = true;

      // Background check if refresh is due
      if (_shouldRefresh(force: false)) {
        // Fire non-blocking refresh
        refresh(force: false).catchError((e) {
          developer.log('Background catalog refresh failed: $e', name: 'BunjiCatalog');
          return _currentCatalog!;
        });
      }
      return cached;
    }

    // 2. No valid cache, try fetching remote directly with short timeout
    try {
      final remote = await _fetchRemoteCatalog();
      if (remote != null) {
        _currentCatalog = remote;
        _isUsingRemote = true;
        return remote;
      }
    } catch (e) {
      developer.log('Initial remote catalog fetch failed: $e', name: 'BunjiCatalog');
    }

    // 3. Fall back to bundled catalog in assets
    return await loadBundledCatalog();
  }

  @override
  Future<ModelCatalog> refresh({bool force = false}) async {
    _lastRefreshTime = DateTime.now();

    if (!force && !_shouldRefresh(force: false)) {
      if (_currentCatalog != null) return _currentCatalog!;
    }

    try {
      final remote = await _fetchRemoteCatalog();
      if (remote != null) {
        _currentCatalog = remote;
        _isUsingRemote = true;
        return remote;
      }
    } catch (e) {
      developer.log('Remote catalog refresh failed: $e', name: 'BunjiCatalog');
    }

    // If remote fails, keep using current or fallback to cache/bundled
    if (_currentCatalog != null) {
      return _currentCatalog!;
    }
    return await load();
  }

  bool _shouldRefresh({required bool force}) {
    if (force) return true;
    if (_currentMetadata == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_currentMetadata!.downloadedAt);
    return difference >= BunjiCatalogConfig.refreshInterval;
  }

  /// Fetches raw JSON from GitHub raw URL, validates schema, and saves to cache.
  Future<ModelCatalog?> _fetchRemoteCatalog() async {
    final uri = Uri.parse(BunjiCatalogConfig.remoteUrl);
    final response = await _client
        .get(uri)
        .timeout(BunjiCatalogConfig.networkTimeout);

    if (response.statusCode != 200) {
      throw HttpException(
        'Failed to fetch remote catalog: HTTP ${response.statusCode}',
        uri: uri,
      );
    }

    final rawJson = utf8.decode(response.bodyBytes);
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Remote catalog root must be a JSON object');
    }

    // Schema version check per Section 21:
    // If schemaVersion != 2, do NOT blindly parse, do NOT crash, do NOT replace working catalog.
    final schemaVersion = decoded['schemaVersion'];
    if (schemaVersion != 2) {
      developer.log(
        'Unsupported model catalog schema version: $schemaVersion. Expected 2.',
        name: 'BunjiCatalog',
      );
      return null;
    }

    // Parse and validate catalog
    final catalog = ModelCatalog.fromJson(decoded);

    // Save to cache
    await _saveToCache(rawJson, catalog.catalogVersion, 'remote');

    _currentMetadata = CatalogCacheMetadata(
      catalogVersion: catalog.catalogVersion,
      downloadedAt: DateTime.now(),
      source: 'remote',
    );

    return catalog;
  }

  /// Loads cached catalog from local disk if valid.
  Future<ModelCatalog?> _loadCachedCatalog() async {
    try {
      final cacheFile = await _getCachedCatalogFile();
      final metaFile = await _getMetadataFile();

      if (!await cacheFile.exists()) return null;

      final content = await cacheFile.readAsString();
      if (content.trim().isEmpty) return null;

      final dynamic decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) return null;

      if (decoded['schemaVersion'] != 2) return null;

      final catalog = ModelCatalog.fromJson(decoded);

      if (await metaFile.exists()) {
        try {
          final metaJson = jsonDecode(await metaFile.readAsString());
          if (metaJson is Map<String, dynamic>) {
            _currentMetadata = CatalogCacheMetadata.fromJson(metaJson);
          }
        } catch (_) {}
      }

      _currentMetadata ??= CatalogCacheMetadata(
        catalogVersion: catalog.catalogVersion,
        downloadedAt: await cacheFile.lastModified(),
        source: 'cache',
      );

      return catalog;
    } catch (e) {
      developer.log('Failed to read cached catalog: $e', name: 'BunjiCatalog');
      return null;
    }
  }

  /// Writes raw downloaded JSON and metadata to local disk cache.
  Future<void> _saveToCache(
    String rawJson,
    String catalogVersion,
    String source,
  ) async {
    try {
      final cacheFile = await _getCachedCatalogFile();
      final metaFile = await _getMetadataFile();

      await cacheFile.writeAsString(rawJson, flush: true);

      final metadata = CatalogCacheMetadata(
        catalogVersion: catalogVersion,
        downloadedAt: DateTime.now(),
        source: source,
      );

      await metaFile.writeAsString(jsonEncode(metadata.toJson()), flush: true);
    } catch (e) {
      developer.log('Failed to cache catalog: $e', name: 'BunjiCatalog');
    }
  }

  @override
  Future<ModelCatalog> loadBundledCatalog() async {
    try {
      final jsonString = await _bundle.loadString(BunjiCatalogConfig.assetPath);
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Bundled catalog root must be a JSON object');
      }

      final catalog = ModelCatalog.fromJson(decoded);
      _currentCatalog = catalog;
      _isUsingRemote = false;
      _currentMetadata = CatalogCacheMetadata(
        catalogVersion: catalog.catalogVersion,
        downloadedAt: DateTime.now(),
        source: 'bundled',
      );
      return catalog;
    } catch (e) {
      developer.log('Failed to load bundled catalog: $e', name: 'BunjiCatalog');
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final cacheFile = await _getCachedCatalogFile();
      final metaFile = await _getMetadataFile();

      if (await cacheFile.exists()) await cacheFile.delete();
      if (await metaFile.exists()) await metaFile.delete();

      _currentMetadata = null;
    } catch (e) {
      developer.log('Failed to clear catalog cache: $e', name: 'BunjiCatalog');
    }
  }
}
