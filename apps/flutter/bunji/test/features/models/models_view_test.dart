import 'package:bunji/app/di.dart';
import 'package:bunji/features/models/models.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTestDatabaseService implements DatabaseService {
  @override
  Future<UserSetting?> getUserSettings([String id = 'default']) async =>
      UserSetting(
        id: 'default',
        themeMode: 'system',
        messageDensity: 'comfortable',
        activeModelId: 'qwen3_0_6b',
        responseStyle: 'Balanced',
        reasoningMode: false,
        streamingTokens: true,
        localAiOnly: true,
        allowInternetForDownloads: true,
        sendDiagnostics: false,
        saveChatHistory: true,
        autoDeleteChats: 'Never',
        bunjiMemory: true,
        enterToSend: true,
        showAiIndicator: true,
        autoScroll: true,
        codeSyntaxHighlighting: true,
        markdownRendering: true,
        autoNameConversations: true,
        reduceMotion: false,
        enableNotifications: true,
        notifyTaskCompletion: true,
        notifyDownloads: true,
        notifyReminders: true,
        launchBehavior: 'Open Home',
        hapticFeedback: true,
        soundEffects: false,
        confirmBeforeDeleting: true,
        appLanguage: 'en',
        aiLanguage: 'auto',
        developerMode: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  @override
  Stream<UserSetting?> watchUserSettings([String id = 'default']) =>
      Stream.value(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTestRepo implements BunjiModelRepository {
  final model = BunjiModel.legacy(
    id: 'qwen3_0_6b',
    displayName: 'Qwen3 0.6B',
    description: 'Ultra-fast on-device LLM',
    repository: 'test/repo',
    revision: 'main',
    filename: 'qwen.gguf',
    parameterCount: 600000000,
    fileSizeBytes: 429000000,
    sha256: 'sha',
    tier: BunjiModelTier.fast,
    minimumRecommendedRamMb: 2048,
  );

  @override
  Future<List<BunjiModel>> getAvailableModels() async => [model];

  @override
  Future<List<BunjiModel>> getInstalledModels() async => [model];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTestCatalog implements BunjiModelCatalog {
  @override
  ModelCatalog? get current => null;

  @override
  bool get isUsingRemoteCatalog => false;

  @override
  CatalogCacheMetadata? get cacheMetadata => null;

  @override
  DateTime? get lastRefreshTime => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTestManager implements BunjiModelManager {
  @override
  Future<BunjiModel?> getActiveModel() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTestDatabaseService fakeDb;
  late FakeTestRepo fakeRepo;
  late FakeTestCatalog fakeCatalog;
  late FakeTestManager fakeManager;

  setUp(() async {
    await sl.reset();
    fakeDb = FakeTestDatabaseService();
    fakeRepo = FakeTestRepo();
    fakeCatalog = FakeTestCatalog();
    fakeManager = FakeTestManager();

    sl.registerLazySingleton<DatabaseService>(() => fakeDb);
    sl.registerLazySingleton<BunjiModelRepository>(() => fakeRepo);
    sl.registerLazySingleton<BunjiModelCatalog>(() => fakeCatalog);
    sl.registerLazySingleton<BunjiModelManager>(() => fakeManager);
    sl.registerFactory<ModelsViewController>(
      () => ModelsViewController(
        databaseService: fakeDb,
        modelRepository: fakeRepo,
        modelCatalog: fakeCatalog,
        modelManager: fakeManager,
      ),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('ModelsView renders active model, catalog list, and filter chips',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: ModelsView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ModelsView), findsOneWidget);
    expect(find.text('Models'), findsOneWidget);
    expect(find.text('All Models'), findsOneWidget);
    expect(find.text('Fast'), findsWidgets);
    expect(find.text('Balanced'), findsWidgets);
    expect(find.text('Quality'), findsWidgets);
    expect(find.text('Model Catalog'), findsOneWidget);
    expect(find.text('Qwen3 0.6B'), findsWidgets);
    expect(find.text('Inference & Response Tuning'), findsOneWidget);
    expect(find.text('Catalog Diagnostics'), findsOneWidget);
  });
}
