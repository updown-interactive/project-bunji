import 'package:bunji/app/bunji.dart';
import 'package:bunji/app/di.dart';
import 'package:bunji/features/onboarding/viewcontrollers/splash_vc.dart';
import 'package:bunji/features/settings/settings.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSettingsDatabaseService implements DatabaseService {
  UserSetting? storedSettings;

  @override
  AppDatabase get db => throw UnimplementedError();

  @override
  Future<UserSetting?> getUserSettings([String id = 'default']) async =>
      storedSettings;

  @override
  Stream<UserSetting?> watchUserSettings([String id = 'default']) =>
      Stream.value(storedSettings);

  @override
  Future<void> saveUserSettings(UserSettingsCompanion settings) async {
    storedSettings = UserSetting(
      id: settings.id.value,
      themeMode: settings.themeMode.present
          ? settings.themeMode.value
          : (storedSettings?.themeMode ?? 'system'),
      messageDensity: settings.messageDensity.present
          ? settings.messageDensity.value
          : (storedSettings?.messageDensity ?? 'comfortable'),
      activeModelId: settings.activeModelId.present
          ? settings.activeModelId.value
          : (storedSettings?.activeModelId ?? 'qwen3_0_6b'),
      responseStyle: settings.responseStyle.present
          ? settings.responseStyle.value
          : (storedSettings?.responseStyle ?? 'Balanced'),
      reasoningMode: settings.reasoningMode.present
          ? settings.reasoningMode.value
          : (storedSettings?.reasoningMode ?? false),
      streamingTokens: settings.streamingTokens.present
          ? settings.streamingTokens.value
          : (storedSettings?.streamingTokens ?? true),
      localAiOnly: settings.localAiOnly.present
          ? settings.localAiOnly.value
          : (storedSettings?.localAiOnly ?? true),
      allowInternetForDownloads: settings.allowInternetForDownloads.present
          ? settings.allowInternetForDownloads.value
          : (storedSettings?.allowInternetForDownloads ?? true),
      sendDiagnostics: settings.sendDiagnostics.present
          ? settings.sendDiagnostics.value
          : (storedSettings?.sendDiagnostics ?? false),
      saveChatHistory: settings.saveChatHistory.present
          ? settings.saveChatHistory.value
          : (storedSettings?.saveChatHistory ?? true),
      autoDeleteChats: settings.autoDeleteChats.present
          ? settings.autoDeleteChats.value
          : (storedSettings?.autoDeleteChats ?? 'Never'),
      bunjiMemory: settings.bunjiMemory.present
          ? settings.bunjiMemory.value
          : (storedSettings?.bunjiMemory ?? true),
      enterToSend: settings.enterToSend.present
          ? settings.enterToSend.value
          : (storedSettings?.enterToSend ?? true),
      showAiIndicator: settings.showAiIndicator.present
          ? settings.showAiIndicator.value
          : (storedSettings?.showAiIndicator ?? true),
      autoScroll: settings.autoScroll.present
          ? settings.autoScroll.value
          : (storedSettings?.autoScroll ?? true),
      codeSyntaxHighlighting: settings.codeSyntaxHighlighting.present
          ? settings.codeSyntaxHighlighting.value
          : (storedSettings?.codeSyntaxHighlighting ?? true),
      markdownRendering: settings.markdownRendering.present
          ? settings.markdownRendering.value
          : (storedSettings?.markdownRendering ?? true),
      autoNameConversations: settings.autoNameConversations.present
          ? settings.autoNameConversations.value
          : (storedSettings?.autoNameConversations ?? true),
      reduceMotion: settings.reduceMotion.present
          ? settings.reduceMotion.value
          : (storedSettings?.reduceMotion ?? false),
      enableNotifications: settings.enableNotifications.present
          ? settings.enableNotifications.value
          : (storedSettings?.enableNotifications ?? true),
      notifyTaskCompletion: settings.notifyTaskCompletion.present
          ? settings.notifyTaskCompletion.value
          : (storedSettings?.notifyTaskCompletion ?? true),
      notifyDownloads: settings.notifyDownloads.present
          ? settings.notifyDownloads.value
          : (storedSettings?.notifyDownloads ?? true),
      notifyReminders: settings.notifyReminders.present
          ? settings.notifyReminders.value
          : (storedSettings?.notifyReminders ?? true),
      launchBehavior: settings.launchBehavior.present
          ? settings.launchBehavior.value
          : (storedSettings?.launchBehavior ?? 'Open Home'),
      hapticFeedback: settings.hapticFeedback.present
          ? settings.hapticFeedback.value
          : (storedSettings?.hapticFeedback ?? true),
      soundEffects: settings.soundEffects.present
          ? settings.soundEffects.value
          : (storedSettings?.soundEffects ?? false),
      confirmBeforeDeleting: settings.confirmBeforeDeleting.present
          ? settings.confirmBeforeDeleting.value
          : (storedSettings?.confirmBeforeDeleting ?? true),
      appLanguage: settings.appLanguage.present
          ? settings.appLanguage.value
          : (storedSettings?.appLanguage ?? 'en'),
      aiLanguage: settings.aiLanguage.present
          ? settings.aiLanguage.value
          : (storedSettings?.aiLanguage ?? 'auto'),
      developerMode: settings.developerMode.present
          ? settings.developerMode.value
          : (storedSettings?.developerMode ?? false),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<UserProfile?> getActiveUserProfile() async => null;
  @override
  Future<UserProfile?> getUserProfile(String id) async => null;
  @override
  Future<void> saveUserProfile(UserProfilesCompanion profile) async {}
  @override
  Future<int> deleteUserProfile(String id) async => 0;
  @override
  Stream<UserProfile?> watchUserProfile(String id) => Stream.value(null);
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
  Future<ChatSession?> getChatSession(String id) async => null;

  @override
  Stream<List<ChatSession>> watchRecentChatSessions({int limit = 50}) =>
      Stream.value([]);

  @override
  Future<List<ChatSession>> getRecentChatSessions({int limit = 50}) async => [];

  @override
  Future<void> saveChatSession(ChatSessionsCompanion session) async {}

  @override
  Future<void> updateChatSessionTitle(String id, String title) async {}

  @override
  Future<void> updateChatSessionCover(String id, String coverImagePath) async {}

  @override
  Future<void> updateChatSessionPin(String id, bool isPinned) async {}

  @override
  Future<void> deleteChatSession(String id) async {}

  @override
  Future<List<DbChatMessage>> getChatMessages(String chatId) async => [];

  @override
  Stream<List<DbChatMessage>> watchChatMessages(String chatId) =>
      Stream.value([]);

  @override
  Future<void> saveChatMessage(ChatMessagesCompanion message) async {}

  @override
  Future<DbChatMessage?> getLatestChatMessage(String chatId) async => null;

  @override
  Future<DbChatMessage?> getLatestAiChatMessage(String chatId) async => null;

  @override
  Future<void> close() async {}
}

class FakeSplashViewController extends SplashViewController {
  FakeSplashViewController() : super();
  @override
  Future<void> init() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeSettingsDatabaseService fakeDb;
  late SettingsViewController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': false});
    await sl.reset();
    fakeDb = FakeSettingsDatabaseService();
    sl.registerLazySingleton<DatabaseService>(() => fakeDb);
    controller = SettingsViewController(databaseService: fakeDb);
    sl.registerLazySingleton<SettingsViewController>(() => controller);
    sl.registerFactory<SplashViewController>(() => FakeSplashViewController());
  });

  tearDown(() async {
    await sl.reset();
  });

  test('SettingsViewController saves and switches theme mode to database', () async {
    expect(controller.state.themeMode, 'System');
    expect(controller.state.flutterThemeMode, ThemeMode.system);

    await controller.updateThemeMode('Dark');
    expect(controller.state.themeMode, 'Dark');
    expect(controller.state.flutterThemeMode, ThemeMode.dark);
    expect(fakeDb.storedSettings?.themeMode, 'dark');

    await controller.updateThemeMode('Light');
    expect(controller.state.themeMode, 'Light');
    expect(controller.state.flutterThemeMode, ThemeMode.light);
    expect(fakeDb.storedSettings?.themeMode, 'light');
  });

  testWidgets('SettingsView renders sections and wires theme mode switching',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsView), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Theme Mode'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    // Tap 'Dark' theme option
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(controller.state.themeMode, 'Dark');
    expect(fakeDb.storedSettings?.themeMode, 'dark');
  });

  testWidgets('Bunji app dynamically updates ThemeMode when settings changes',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const Bunji());
    await tester.pump();

    // Verify MaterialApp.router uses system theme initially
    var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.system);

    // Change to Dark
    await controller.updateThemeMode('Dark');
    await tester.pump();

    materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);

    // Change to Light
    await controller.updateThemeMode('Light');
    await tester.pump();

    materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.light);
  });
}
