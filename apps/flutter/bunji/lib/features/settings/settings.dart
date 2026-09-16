import 'package:bunji/features/settings/viewcontroller/settings_vc.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:get_it/get_it.dart';

export 'viewcontroller/settings_state.dart';
export 'viewcontroller/settings_vc.dart';
export 'view/settings_view.dart';

void registerSettings(GetIt sl) {
  sl.registerLazySingleton(
    () => SettingsViewController(
      databaseService: sl<DatabaseService>(),
      modelRepository: sl<BunjiModelRepository>(),
      modelCatalog: sl<BunjiModelCatalog>(),
      modelManager: sl<BunjiModelManager>(),
    ),
  );
}
