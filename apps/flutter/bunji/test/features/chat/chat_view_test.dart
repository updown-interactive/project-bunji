import 'dart:async';
import 'dart:io';
import 'package:bunji/app/di.dart';
import 'package:bunji/features/chat/chat.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeInferenceEngine implements BunjiInferenceEngine {
  bool loaded = true;

  @override
  bool get isModelLoaded => loaded;

  @override
  Future<bool> loadModel(File modelFile) async => true;

  @override
  Future<void> unloadModel() async => loaded = false;

  Stream<String>? customStream;

  @override
  Stream<String> generateStream(
    String prompt, {
    bool isReasoning = false,
  }) async* {
    if (customStream != null) {
      yield* customStream!;
      return;
    }
    yield 'Hello from Bunji!';
  }

  @override
  Future<HealthCheckResult> runHealthCheck() async {
    return const HealthCheckResult(
      isHealthy: true,
      latency: Duration(milliseconds: 5),
    );
  }

  @override
  Future<void> stopGeneration() async {}
}

class FakeModelManager implements BunjiModelManager {
  BunjiModel? activeModel;
  bool installed = true;

  @override
  Future<BunjiModel?> getActiveModel() async => activeModel;

  @override
  Future<bool> hasValidInstalledModel() async => installed;

  @override
  Stream<UserAiModel?> watchActiveModel() => const Stream.empty();

  @override
  Future<InstalledModelRecord?> getActiveInstalledModelRecord() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDatabaseService implements DatabaseService {
  @override
  Future<UserSetting?> getUserSettings([String id = 'default']) async => null;

  @override
  Future<void> saveChatSession(ChatSessionsCompanion session) async {}

  @override
  Future<void> saveChatMessage(ChatMessagesCompanion message) async {}

  @override
  Future<void> updateChatSessionTitle(String id, String title) async {}

  @override
  Future<void> updateChatSessionCover(String id, String coverImagePath) async {}

  ChatSession? sessionToReturn;

  @override
  Future<ChatSession?> getChatSession(String id) async => sessionToReturn;

  @override
  Future<List<DbChatMessage>> getChatMessages(String chatId) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatView Widget Tests', () {
    late FakeInferenceEngine engine;
    late FakeModelManager manager;
    late FakeDatabaseService db;

    final sampleModel = BunjiModel.legacy(
      id: 'qwen3_0_6b',
      displayName: 'Qwen 3 0.6B',
      description: 'Ultra-lightweight on-device model.',
      repository: 'Qwen/Qwen3-0.6B-GGUF',
      revision: 'main',
      filename: 'qwen3-0.6b-q4_k_m.gguf',
      parameterCount: 600000000,
      fileSizeBytes: 450000000,
      sha256: 'abc123sha256',
      tier: BunjiModelTier.balanced,
      minimumRecommendedRamMb: 2048,
      recommended: true,
    );

    setUp(() async {
      await sl.reset();
      engine = FakeInferenceEngine();
      manager = FakeModelManager()..activeModel = sampleModel;
      db = FakeDatabaseService();

      sl.registerLazySingleton<BunjiInferenceEngine>(() => engine);
      sl.registerLazySingleton<BunjiModelManager>(() => manager);
      sl.registerLazySingleton<DatabaseService>(() => db);
      registerChat(sl);
    });

    tearDown(() async {
      await sl.reset();
    });

    testWidgets('renders app bar with active model name and empty state suggestions',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: ChatView(),
        ),
      );

      // Settle initial controller init
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Title in App Bar
      expect(find.text('Conversation'), findsOneWidget);

      // Verify Model name chip in App Bar action item
      expect(find.text('Qwen 3 0.6B'), findsOneWidget);

      // Verify Empty State & Suggestions
      expect(find.text('What can I help with?'), findsOneWidget);
      expect(find.text('Suggested Prompts'), findsOneWidget);
      expect(
        find.text('How does on-device AI protect my privacy compared to cloud models?'),
        findsOneWidget,
      );
    });

    testWidgets('renders loaded chat title in app bar and model in action item',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      db.sessionToReturn = ChatSession(
        id: 'test-session-1',
        title: 'Exploring Australia',
        coverImagePath: null,
        modelId: 'qwen3_0_6b',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPinned: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ChatView(chatId: 'test-session-1'),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify chat title is in app bar
      expect(find.text('Exploring Australia'), findsOneWidget);
      // Verify active model is in action item
      expect(find.text('Qwen 3 0.6B'), findsOneWidget);
    });

    testWidgets('sends suggestion prompt and displays user message & AI response',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: ChatView(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final prompt = 'Summarize the core benefits of running local LLMs.';
      final promptFinder = find.text(prompt);
      expect(promptFinder, findsOneWidget);

      await tester.tap(promptFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check that user message appears
      expect(find.text(prompt), findsOneWidget);
      // Check that AI response appears
      expect(find.text('Hello from Bunji!'), findsOneWidget);
    });

    testWidgets('renders warning banner when no model is installed',
        (tester) async {
      manager.installed = false;
      manager.activeModel = null;

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: ChatView(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Bunji AI'), findsOneWidget);
      expect(
        find.text('No local model ready. Download one to start chatting.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping app bar action expands options menu with model modes',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: ChatView(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially, the model name is visible in the app bar action chip
      final modelActionFinder = find.text('Qwen 3 0.6B');
      expect(modelActionFinder, findsOneWidget);

      // Tap the app bar action chip to expand options
      await tester.tap(modelActionFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Verify the expanded options menu is shown with Model Mode options
      expect(find.text('MODEL MODE'), findsOneWidget);
      expect(find.text('Thinking Mode'), findsOneWidget);
      expect(find.text('Fast Mode'), findsOneWidget);
      expect(find.text('Change Model'), findsOneWidget);
      expect(find.text('Clear Messages'), findsOneWidget);

      // Tap Thinking Mode to switch mode
      await tester.tap(find.text('Thinking Mode'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Re-open to confirm Thinking Mode is active
      await tester.tap(modelActionFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Thinking Mode'), findsOneWidget);
    });

    testWidgets('shows pulsing blip indicator while message is loading',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final streamController = StreamController<String>();
      engine.customStream = streamController.stream;

      await tester.pumpWidget(
        const MaterialApp(
          home: ChatView(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final prompt = 'Summarize the core benefits of running local LLMs.';
      final promptFinder = find.text(prompt);
      expect(promptFinder, findsOneWidget);

      await tester.tap(promptFinder);
      await tester.pump();

      // Verify that pulsing blip AnimatedBuilder is displayed while streaming with empty responseText
      expect(find.byType(AnimatedBuilder), findsWidgets);

      // Finish generation
      streamController.add('Quantum computing is fascinating.');
      await streamController.close();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Quantum computing is fascinating.'), findsOneWidget);
    });
  });
}
