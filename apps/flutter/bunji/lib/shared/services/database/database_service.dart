import 'package:drift/drift.dart';
import 'app_database.dart';

/// Contract for the local database client service.
abstract class DatabaseService {
  /// Direct reference to the Drift [AppDatabase] instance.
  AppDatabase get db;

  /// Retrieves a user profile by [id].
  Future<UserProfile?> getUserProfile(String id);

  /// Retrieves the active/first user profile if one exists.
  Future<UserProfile?> getActiveUserProfile();

  /// Watches a user profile by [id] as a reactive stream.
  Stream<UserProfile?> watchUserProfile(String id);

  /// Creates or updates a user profile.
  Future<void> saveUserProfile(UserProfilesCompanion profile);

  /// Deletes a user profile by [id].
  Future<int> deleteUserProfile(String id);

  /// Closes the database connection.
  Future<void> close();

  // -------------------------------------------------------------
  // AI Models Management (Multiple models support & switching)
  // -------------------------------------------------------------

  /// Retrieves all downloaded & installed AI models.
  Future<List<UserAiModel>> getInstalledAiModels();

  /// Watches all installed AI models reactively.
  Stream<List<UserAiModel>> watchInstalledAiModels();

  /// Retrieves the currently active AI model for inference.
  Future<UserAiModel?> getActiveAiModel();

  /// Watches the currently active AI model reactively.
  Stream<UserAiModel?> watchActiveAiModel();

  /// Retrieves a specific AI model by [id].
  Future<UserAiModel?> getAiModel(String id);

  /// Saves or updates an AI model record in the database.
  Future<void> saveAiModel(UserAiModelsCompanion model);

  /// Switches the active AI model to [id]. Deactivates all other models.
  Future<void> setActiveAiModel(String id);

  /// Deletes an AI model record from the database.
  Future<int> deleteAiModel(String id);

  // -------------------------------------------------------------
  // User Settings Management
  // -------------------------------------------------------------

  /// Retrieves user settings by [id] (defaults to 'default').
  Future<UserSetting?> getUserSettings([String id = 'default']);

  /// Watches user settings by [id] reactively (defaults to 'default').
  Stream<UserSetting?> watchUserSettings([String id = 'default']);

  /// Saves or updates user settings.
  Future<void> saveUserSettings(UserSettingsCompanion settings);
}

/// Concrete implementation of [DatabaseService].
class DatabaseServiceImpl implements DatabaseService {
  final AppDatabase _db;

  DatabaseServiceImpl({AppDatabase? db}) : _db = db ?? AppDatabase();

  @override
  AppDatabase get db => _db;

  @override
  Future<UserProfile?> getUserProfile(String id) {
    return (_db.select(_db.userProfiles)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<UserProfile?> getActiveUserProfile() {
    return (_db.select(_db.userProfiles)..limit(1)).getSingleOrNull();
  }

  @override
  Stream<UserProfile?> watchUserProfile(String id) {
    return (_db.select(_db.userProfiles)..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull();
  }

  @override
  Future<void> saveUserProfile(UserProfilesCompanion profile) {
    return _db.into(_db.userProfiles).insertOnConflictUpdate(profile);
  }

  @override
  Future<int> deleteUserProfile(String id) {
    return (_db.delete(_db.userProfiles)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // -------------------------------------------------------------
  // AI Models Implementation
  // -------------------------------------------------------------

  @override
  Future<List<UserAiModel>> getInstalledAiModels() {
    return (_db.select(_db.userAiModels)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.installedAt)]))
        .get();
  }

  @override
  Stream<List<UserAiModel>> watchInstalledAiModels() {
    return (_db.select(_db.userAiModels)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.installedAt)]))
        .watch();
  }

  @override
  Future<UserAiModel?> getActiveAiModel() {
    return (_db.select(_db.userAiModels)
          ..where((tbl) => tbl.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  @override
  Stream<UserAiModel?> watchActiveAiModel() {
    return (_db.select(_db.userAiModels)
          ..where((tbl) => tbl.isActive.equals(true))
          ..limit(1))
        .watchSingleOrNull();
  }

  @override
  Future<UserAiModel?> getAiModel(String id) {
    return (_db.select(_db.userAiModels)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<void> saveAiModel(UserAiModelsCompanion model) {
    return _db.into(_db.userAiModels).insertOnConflictUpdate(model);
  }

  @override
  Future<void> setActiveAiModel(String id) async {
    await _db.transaction(() async {
      // Deactivate all models
      await (_db.update(_db.userAiModels))
          .write(const UserAiModelsCompanion(isActive: Value(false)));

      // Activate the selected model and update its lastUsedAt timestamp
      await (_db.update(_db.userAiModels)..where((tbl) => tbl.id.equals(id)))
          .write(
        UserAiModelsCompanion(
          isActive: const Value(true),
          lastUsedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<int> deleteAiModel(String id) {
    return (_db.delete(_db.userAiModels)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // -------------------------------------------------------------
  // User Settings Implementation
  // -------------------------------------------------------------

  @override
  Future<UserSetting?> getUserSettings([String id = 'default']) {
    return (_db.select(_db.userSettings)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Stream<UserSetting?> watchUserSettings([String id = 'default']) {
    return (_db.select(_db.userSettings)..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull();
  }

  @override
  Future<void> saveUserSettings(UserSettingsCompanion settings) {
    return _db.into(_db.userSettings).insertOnConflictUpdate(settings);
  }

  @override
  Future<void> close() => _db.close();
}
