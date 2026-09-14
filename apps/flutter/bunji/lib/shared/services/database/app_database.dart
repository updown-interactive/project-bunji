import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/user_ai_models_table.dart';
import 'tables/user_profiles_table.dart';
import 'tables/user_settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [UserProfiles, UserAiModels, UserSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

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
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'bunji_db');
  }
}
