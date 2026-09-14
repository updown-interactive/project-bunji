import 'package:bunji/features/onboarding/viewcontrollers/onboarding_vc.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeDatabaseService implements DatabaseService {
  UserProfile? storedProfile;

  @override
  AppDatabase get db => throw UnimplementedError();

  @override
  Future<UserProfile?> getActiveUserProfile() async => storedProfile;

  @override
  Future<UserProfile?> getUserProfile(String id) async => storedProfile;

  @override
  Future<void> saveUserProfile(UserProfilesCompanion profile) async {
    storedProfile = UserProfile(
      id: profile.id.value,
      name: profile.name.value,
      gender: profile.gender.value,
      dob: profile.dob.value,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<int> deleteUserProfile(String id) async {
    storedProfile = null;
    return 1;
  }

  @override
  Stream<UserProfile?> watchUserProfile(String id) => Stream.value(storedProfile);

  final List<UserAiModel> storedModels = [];

  @override
  Future<List<UserAiModel>> getInstalledAiModels() async => List.unmodifiable(storedModels);

  @override
  Stream<List<UserAiModel>> watchInstalledAiModels() => Stream.value(storedModels);

  @override
  Future<UserAiModel?> getActiveAiModel() async {
    try {
      return storedModels.firstWhere((m) => m.isActive);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<UserAiModel?> watchActiveAiModel() async* {
    yield await getActiveAiModel();
  }

  @override
  Future<UserAiModel?> getAiModel(String id) async {
    try {
      return storedModels.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveAiModel(UserAiModelsCompanion model) async {
    storedModels.removeWhere((m) => m.id == model.id.value);
    storedModels.add(
      UserAiModel(
        id: model.id.value,
        displayName: model.displayName.value,
        tier: model.tier.value,
        version: model.version.value,
        filePath: model.filePath.value,
        fileSizeBytes: model.fileSizeBytes.value,
        sha256: model.sha256.value,
        isVerified: model.isVerified.value,
        isActive: model.isActive.value,
        installedAt: model.installedAt.value,
        lastUsedAt: model.lastUsedAt.value,
      ),
    );
  }

  @override
  Future<void> setActiveAiModel(String id) async {
    for (int i = 0; i < storedModels.length; i++) {
      final current = storedModels[i];
      final isTarget = current.id == id;
      storedModels[i] = current.copyWith(
        isActive: isTarget,
        lastUsedAt: isTarget ? Value(DateTime.now()) : Value(current.lastUsedAt),
      );
    }
  }

  @override
  Future<int> deleteAiModel(String id) async {
    final count = storedModels.where((m) => m.id == id).length;
    storedModels.removeWhere((m) => m.id == id);
    return count;
  }

  @override
  Future<UserSetting?> getUserSettings([String id = 'default']) async => null;

  @override
  Stream<UserSetting?> watchUserSettings([String id = 'default']) =>
      Stream.value(null);

  @override
  Future<void> saveUserSettings(UserSettingsCompanion settings) async {}

  @override
  Future<void> close() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingViewController AI Model Flow Tests', () {
    late FakeDatabaseService fakeDb;
    late BunjiModelManager modelManager;
    late OnboardingViewController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => '/tmp',
      );
      fakeDb = FakeDatabaseService();

      modelManager = BunjiModelManager(
        downloader: BunjiModelDownloader(),
        verifier: BunjiModelVerifier(),
        deviceCapabilities: BunjiDeviceCapabilities(),
        inferenceEngine: BunjiLocalInferenceEngine(),
        databaseService: fakeDb,
      );

      controller = OnboardingViewController(
        databaseService: fakeDb,
        modelManager: modelManager,
      );
    });

    tearDown(() async {
      await controller.close();
    });

    test('initial step is 0 and default model is Qwen3 0.6B', () async {
      expect(controller.state.step, equals(0));
      expect(controller.state.name, isEmpty);
      await controller.init();
      expect(controller.state.selectedModel?.displayName, equals('Qwen3 0.6B'));
    });

    test('step 0 validation prevents moving forward with empty name', () {
      controller.nextStep();
      expect(controller.state.step, equals(0));
      expect(controller.state.ui.action, isA<ShowError>());
    });

    test('profile submission saves to drift and moves to Step 2 (Model Selection)',
        () async {
      controller.updateName('Sivasankar');
      controller.nextStep();
      expect(controller.state.step, equals(1));

      controller.updateGender('Male');
      controller.updateDob(DateTime(1995, 5, 20));

      await controller.submitProfile();

      // Crucial: Step is now 2 (Model Selection), NOT navigating away to Home!
      expect(controller.state.step, equals(2));
      expect(fakeDb.storedProfile?.name, equals('Sivasankar'));
      expect(controller.state.selectedModel, isNotNull);
    });

    test('explicit model selection changes selected model', () async {
      final reasoningModel = BunjiModel.availableModels
          .firstWhere((m) => m.tier == BunjiModelTier.reasoning);

      controller.selectModel(reasoningModel);
      expect(controller.state.selectedModel?.id, equals(reasoningModel.id));
    });

    test('toggle download confirmation state', () {
      controller.selectModel(BunjiModel.availableModels.first);
      controller.showDownloadConfirmation();
      expect(controller.state.isConfirmingDownload, isTrue);

      controller.cancelConfirmation();
      expect(controller.state.isConfirmingDownload, isFalse);
    });

    test('supports downloading multiple models and switching active model in database', () async {
      final fastModel = BunjiModel.availableModels[0];
      final reasoningModel = BunjiModel.availableModels[1];

      // 1. Install first model
      await modelManager.installModel(model: fastModel, simulatedDemo: true);
      expect(fakeDb.storedModels.length, equals(1));
      expect(fakeDb.storedModels.first.id, equals(fastModel.id));
      expect(fakeDb.storedModels.first.isActive, isTrue);

      // 2. Install second model
      await modelManager.installModel(model: reasoningModel, simulatedDemo: true);
      expect(fakeDb.storedModels.length, equals(2));
      expect((await modelManager.getActiveModel())?.id, equals(reasoningModel.id));

      // 3. Switch back to first model
      await modelManager.switchActiveModel(fastModel.id);
      final active = await modelManager.getActiveModel();
      expect(active?.id, equals(fastModel.id));
      expect(active?.isActive, isTrue);

      final other = await fakeDb.getAiModel(reasoningModel.id);
      expect(other?.isActive, isFalse);
    });

    test('completeOnboarding marks manager completed and routes to Home', () async {
      await controller.completeOnboarding();
      expect(controller.state.ui.action, isA<NavigateTo>());
      final navAction = controller.state.ui.action as NavigateTo;
      expect(navAction.route.name, equals('home'));
    });
  });
}
