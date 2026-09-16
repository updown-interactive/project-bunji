import 'package:bunji/features/onboarding/viewcontrollers/onboarding_vc.dart';
import 'package:bunji/features/onboarding/viewcontrollers/splash_vc.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:get_it/get_it.dart';

void registerOnboarding(GetIt sl) {
  sl.registerFactory<SplashViewController>(
    () => SplashViewController(
      databaseService: sl<DatabaseService>(),
      modelManager: sl<BunjiModelManager>(),
    ),
  );
  sl.registerFactory<OnboardingViewController>(
    () => OnboardingViewController(
      databaseService: sl<DatabaseService>(),
      modelManager: sl<BunjiModelManager>(),
      modelRepository: sl<BunjiModelRepository>(),
    ),
  );
}