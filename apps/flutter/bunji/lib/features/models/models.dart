import 'package:bunji/features/models/viewcontroller/models_vc.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:get_it/get_it.dart';

export 'viewcontroller/models_state.dart';
export 'viewcontroller/models_vc.dart';
export 'view/models_view.dart';

void registerModels(GetIt sl) {
  sl.registerFactory(
    () => ModelsViewController(
      databaseService: sl<DatabaseService>(),
      modelRepository: sl<BunjiModelRepository>(),
      modelCatalog: sl<BunjiModelCatalog>(),
      modelManager: sl<BunjiModelManager>(),
    ),
  );
}
