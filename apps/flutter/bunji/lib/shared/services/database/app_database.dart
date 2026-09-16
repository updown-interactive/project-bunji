import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/chat_messages_table.dart';
import 'tables/chat_sessions_table.dart';
import 'tables/user_ai_models_table.dart';
import 'tables/user_profiles_table.dart';
import 'tables/user_settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserProfiles,
    UserAiModels,
    UserSettings,
    ChatSessions,
    ChatMessages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(userAiModels);
          }
          if (from < 3) {
            await m.createTable(userSettings);
          }
          if (from < 4) {
            await m.createTable(chatSessions);
            await m.createTable(chatMessages);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'bunji_db');
  }
}
