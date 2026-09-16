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

  // -------------------------------------------------------------
  // Chat Sessions & Messages Management
  // -------------------------------------------------------------

  /// Retrieves a chat session by [id].
  Future<ChatSession?> getChatSession(String id);

  /// Watches all recent chat sessions, sorted by last update descending.
  Stream<List<ChatSession>> watchRecentChatSessions({int limit = 50});

  /// Retrieves recent chat sessions.
  Future<List<ChatSession>> getRecentChatSessions({int limit = 50});

  /// Saves or updates a chat session.
  Future<void> saveChatSession(ChatSessionsCompanion session);

  /// Updates the title of a chat session.
  Future<void> updateChatSessionTitle(String id, String title);

  /// Updates the cover image of a chat session.
  Future<void> updateChatSessionCover(String id, String coverImagePath);

  /// Updates the pinned status of a chat session.
  Future<void> updateChatSessionPin(String id, bool isPinned);

  /// Deletes a chat session and all its messages.
  Future<void> deleteChatSession(String id);

  /// Retrieves all messages for a given chat session, sorted chronologically.
  Future<List<DbChatMessage>> getChatMessages(String chatId);

  /// Watches all messages for a given chat session as a reactive stream.
  Stream<List<DbChatMessage>> watchChatMessages(String chatId);

  /// Saves a message to the database.
  Future<void> saveChatMessage(ChatMessagesCompanion message);

  /// Retrieves the latest message for a chat session.
  Future<DbChatMessage?> getLatestChatMessage(String chatId);

  /// Retrieves the latest AI message for a chat session.
  Future<DbChatMessage?> getLatestAiChatMessage(String chatId);
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

  // -------------------------------------------------------------
  // Chat Sessions & Messages Implementation
  // -------------------------------------------------------------

  @override
  Future<ChatSession?> getChatSession(String id) {
    return (_db.select(_db.chatSessions)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Stream<List<ChatSession>> watchRecentChatSessions({int limit = 50}) {
    return (_db.select(_db.chatSessions)
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.updatedAt,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(limit))
        .watch();
  }

  @override
  Future<List<ChatSession>> getRecentChatSessions({int limit = 50}) {
    return (_db.select(_db.chatSessions)
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.updatedAt,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(limit))
        .get();
  }

  @override
  Future<void> saveChatSession(ChatSessionsCompanion session) {
    return _db.into(_db.chatSessions).insertOnConflictUpdate(session);
  }

  @override
  Future<void> updateChatSessionTitle(String id, String title) {
    return (_db.update(_db.chatSessions)..where((tbl) => tbl.id.equals(id)))
        .write(ChatSessionsCompanion(
      title: Value(title),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> updateChatSessionCover(String id, String coverImagePath) {
    return (_db.update(_db.chatSessions)..where((tbl) => tbl.id.equals(id)))
        .write(ChatSessionsCompanion(
      coverImagePath: Value(coverImagePath),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> updateChatSessionPin(String id, bool isPinned) {
    return (_db.update(_db.chatSessions)..where((tbl) => tbl.id.equals(id)))
        .write(ChatSessionsCompanion(
      isPinned: Value(isPinned),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> deleteChatSession(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.chatMessages)
            ..where((tbl) => tbl.chatId.equals(id)))
          .go();
      await (_db.delete(_db.chatSessions)..where((tbl) => tbl.id.equals(id)))
          .go();
    });
  }

  @override
  Future<List<DbChatMessage>> getChatMessages(String chatId) {
    return (_db.select(_db.chatMessages)
          ..where((tbl) => tbl.chatId.equals(chatId))
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.timestamp,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  @override
  Stream<List<DbChatMessage>> watchChatMessages(String chatId) {
    return (_db.select(_db.chatMessages)
          ..where((tbl) => tbl.chatId.equals(chatId))
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.timestamp,
                  mode: OrderingMode.asc,
                ),
          ]))
        .watch();
  }

  @override
  Future<void> saveChatMessage(ChatMessagesCompanion message) {
    return _db.into(_db.chatMessages).insertOnConflictUpdate(message);
  }

  @override
  Future<DbChatMessage?> getLatestChatMessage(String chatId) {
    return (_db.select(_db.chatMessages)
          ..where((tbl) => tbl.chatId.equals(chatId))
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.timestamp,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  @override
  Future<DbChatMessage?> getLatestAiChatMessage(String chatId) {
    return (_db.select(_db.chatMessages)
          ..where((tbl) => tbl.chatId.equals(chatId) & tbl.sender.equals('ai'))
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.timestamp,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  @override
  Future<void> close() => _db.close();
}
