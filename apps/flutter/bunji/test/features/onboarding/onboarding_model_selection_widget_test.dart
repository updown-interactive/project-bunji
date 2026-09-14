import 'package:bunji/app/di.dart';
import 'package:bunji/features/onboarding/view/onboarding_view.dart';
import 'package:bunji/features/onboarding/viewcontrollers/onboarding_vc.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeTestDatabaseService implements DatabaseService {
  UserProfile? storedProfile;

  @override
  AppDatabase get db => throw UnimplementedError();

  @override
  Future<UserProfile?> getActiveUserProfile() async => storedProfile;

  @override
  Future<UserProfile?> getUserProfile(String id) async => storedProfile;

  @override
  Future<void> saveUserProfile(UserProfilesCompanion profile) async {}

  @override
  Future<int> deleteUserProfile(String id) async => 1;

  @override
  Stream<UserProfile?> watchUserProfile(String id) => Stream.value(storedProfile);

  @override
  Future<List<UserAiModel>> getInstalledAiModels() async => [];

  @override
  Stream<List<UserAiModel>> watchInstalledAiModels() => Stream.value([]);

  @override
  Future<UserAiModel?> getActiveAiModel() async => null;

  @override
  Stream<UserAiModel?> watchActiveAiModel() => Stream.value(null);

  @override
  Future<UserAiModel?> getAiModel(String id) async => null;

  @override
  Future<void> saveAiModel(UserAiModelsCompanion model) async {}

  @override
  Future<void> setActiveAiModel(String id) async {}

  @override
  Future<int> deleteAiModel(String id) async => 0;

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
  late OnboardingViewController controller;
  late FakeTestDatabaseService fakeDb;

  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '/tmp',
    );

    fakeDb = FakeTestDatabaseService();
    fakeDb.storedProfile = UserProfile(
      id: 'test_user_id',
      name: 'TestUser',
      gender: 'Male',
      dob: DateTime(1995, 5, 20),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final modelManager = BunjiModelManager(
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

    sl.registerFactory<OnboardingViewController>(() => controller);
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets(
      'Step 2 Model selection displays in 2 columns, has no emojis, and expands on tap',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingView(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify model titles are visible
    expect(find.text('Qwen3 0.6B'), findsOneWidget);
    expect(find.text('MobileLLM-R1.5 950M'), findsOneWidget);
    expect(find.text('Qwen3 1.7B'), findsOneWidget);

    // 2. Verify NO emojis are rendered
    expect(find.textContaining('⚡'), findsNothing);
    expect(find.textContaining('🧠'), findsNothing);
    expect(find.textContaining('✨'), findsNothing);

    // 3. Verify that initially (collapsed/show less details), detailed bullet highlights are hidden
    expect(find.text('Uses less storage'), findsNothing);
    expect(find.text('Better reasoning'), findsNothing);

    // 4. Tap the first model (Qwen3 0.6B) to expand it
    await tester.tap(find.text('Qwen3 0.6B'));
    await tester.pumpAndSettle();

    // Now Qwen3 0.6B details should be visible!
    expect(
        find.text('Small and fast for everyday conversations.'), findsOneWidget);
    expect(find.text('Uses less storage'), findsOneWidget);
    expect(find.text('Fast responses'), findsOneWidget);

    // MobileLLM details should still be collapsed
    expect(find.text('Better reasoning'), findsNothing);

    // 5. Tap MobileLLM-R1.5 950M -> it should expand, and Qwen3 should collapse
    await tester.tap(find.text('MobileLLM-R1.5 950M'));
    await tester.pumpAndSettle();

    expect(find.text('Better reasoning'), findsOneWidget);
    expect(
        find.text(
            'More capable reasoning while remaining small enough for modern phones.'),
        findsOneWidget);
    // Qwen3 0.6B details should now be collapsed
    expect(find.text('Uses less storage'), findsNothing);

    // 6. Tap MobileLLM-R1.5 950M again -> collapses
    await tester.tap(find.text('MobileLLM-R1.5 950M'));
    await tester.pumpAndSettle();

    expect(find.text('Better reasoning'), findsNothing);
  });
}
