import 'package:bunji/shared/ai/services/bunji_device_capabilities.dart';
import 'package:bunji/shared/ai/services/bunji_inference_engine.dart';
import 'package:bunji/shared/ai/services/bunji_model_catalog.dart';
import 'package:bunji/shared/ai/services/bunji_model_downloader.dart';
import 'package:bunji/shared/ai/services/bunji_model_manager.dart';
import 'package:bunji/shared/ai/services/bunji_model_repository.dart';
import 'package:bunji/shared/ai/services/bunji_model_verifier.dart';
import 'package:get_it/get_it.dart';
import 'database/app_database.dart';
import 'database/database_service.dart';

export 'package:bunji/shared/ai/config/bunji_catalog_config.dart';
export 'package:bunji/shared/ai/models/bunji_model.dart';
export 'package:bunji/shared/ai/services/bunji_device_capabilities.dart';
export 'package:bunji/shared/ai/services/bunji_inference_engine.dart';
export 'package:bunji/shared/ai/services/bunji_model_catalog.dart';
export 'package:bunji/shared/ai/services/bunji_model_downloader.dart';
export 'package:bunji/shared/ai/services/bunji_model_manager.dart';
export 'package:bunji/shared/ai/services/bunji_model_repository.dart';
export 'package:bunji/shared/ai/services/bunji_model_verifier.dart';
export 'database/app_database.dart';
export 'database/database_service.dart';
export 'database/tables/user_profiles_table.dart';
export 'database/tables/user_ai_models_table.dart';
export 'database/tables/user_settings_table.dart';

/// Registers all shared infrastructure & database client services into GetIt.
void registerServices(GetIt sl) {
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  sl.registerLazySingleton<DatabaseService>(
    () => DatabaseServiceImpl(db: sl<AppDatabase>()),
  );

  sl.registerLazySingleton<BunjiDeviceCapabilities>(
    () => BunjiDeviceCapabilities(),
  );
  sl.registerLazySingleton<BunjiModelDownloader>(() => BunjiModelDownloader());
  sl.registerLazySingleton<BunjiModelVerifier>(() => BunjiModelVerifier());
  sl.registerLazySingleton<BunjiInferenceEngine>(
    () => BunjiLocalInferenceEngine(),
  );

  // Model Catalog & Repository
  sl.registerLazySingleton<BunjiModelCatalog>(
    () => BunjiModelCatalogManager(),
  );
  sl.registerLazySingleton<BunjiModelRepository>(
    () => BunjiModelRepositoryImpl(
      catalog: sl<BunjiModelCatalog>(),
      databaseService: sl<DatabaseService>(),
    ),
  );

  sl.registerLazySingleton<BunjiModelManager>(
    () => BunjiModelManager(
      downloader: sl<BunjiModelDownloader>(),
      verifier: sl<BunjiModelVerifier>(),
      deviceCapabilities: sl<BunjiDeviceCapabilities>(),
      inferenceEngine: sl<BunjiInferenceEngine>(),
      databaseService: sl<DatabaseService>(),
      repository: sl<BunjiModelRepository>(),
    ),
  );
}
