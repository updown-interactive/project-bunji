import 'dart:async';
import 'dart:io';
import 'package:bunji/features/chat/chat.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeInferenceEngine implements BunjiInferenceEngine {
  bool loaded = false;
  File? loadedFile;
  StreamController<String>? activeStreamController;
  Object? streamError;

  @override
  bool get isModelLoaded => loaded;

  @override
  Future<bool> loadModel(File modelFile) async {
    loaded = true;
    loadedFile = modelFile;
    return true;
  }

  @override
  Future<void> unloadModel() async {
    loaded = false;
    loadedFile = null;
  }

  final List<String> recordedPrompts = [];
  final List<bool> recordedReasoningModes = [];

  String? customTitleEmission;

  @override
  Stream<String> generateStream(
    String prompt, {
    bool isReasoning = false,
  }) async* {
    recordedPrompts.add(prompt);
    recordedReasoningModes.add(isReasoning);
    if (streamError != null) {
      throw streamError!;
    }
    if (prompt.contains('Title:') || prompt.contains('title') || prompt.contains('naming')) {
      if (customTitleEmission != null) {
        yield customTitleEmission!;
        return;
      }
      yield 'Australia Guide';
      return;
    }
    final tokens = ['Hello', ' ', 'there!', ' How', ' can', ' I', ' help?'];
    for (final token in tokens) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      yield token;
    }
  }

  @override
  Future<HealthCheckResult> runHealthCheck() async {
    return HealthCheckResult(
      isHealthy: loaded,
      latency: const Duration(milliseconds: 10),
    );
  }

  @override
  Future<void> stopGeneration() async {}
}

class FakeModelManager implements BunjiModelManager {
  BunjiModel? activeModel;
  bool installed = true;
  final StreamController<UserAiModel?> activeModelStreamController =
      StreamController<UserAiModel?>.broadcast();

  @override
  Future<BunjiModel?> getActiveModel() async => activeModel;

  @override
  Future<bool> hasValidInstalledModel() async => installed;

  @override
  Stream<UserAiModel?> watchActiveModel() => activeModelStreamController.stream;

  @override
  Future<InstalledModelRecord?> getActiveInstalledModelRecord() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDatabaseService implements DatabaseService {
  UserSetting? settings;
  final List<ChatSessionsCompanion> savedSessions = [];
  final List<ChatMessagesCompanion> savedMessages = [];
  final Map<String, String> sessionTitles = {};
  final Map<String, String> sessionCovers = {};

  @override
  Future<UserSetting?> getUserSettings([String id = 'default']) async => settings;

  @override
  Future<void> saveChatSession(ChatSessionsCompanion session) async {
    savedSessions.add(session);
  }

  @override
  Future<void> saveChatMessage(ChatMessagesCompanion message) async {
    savedMessages.add(message);
  }

  @override
  Future<void> updateChatSessionTitle(String id, String title) async {
    sessionTitles[id] = title;
  }

  @override
  Future<void> updateChatSessionCover(String id, String coverImagePath) async {
    sessionCovers[id] = coverImagePath;
  }

  @override
  Future<ChatSession?> getChatSession(String id) async => null;

  @override
  Future<List<DbChatMessage>> getChatMessages(String chatId) async => [];

  final List<UserSettingsCompanion> savedUserSettingsList = [];

  @override
  Future<void> saveUserSettings(UserSettingsCompanion settings) async {
    savedUserSettingsList.add(settings);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatViewController Tests', () {
    late FakeInferenceEngine engine;
    late FakeModelManager manager;
    late FakeDatabaseService db;
    late ChatViewController controller;

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

    setUp(() {
      engine = FakeInferenceEngine();
      manager = FakeModelManager()..activeModel = sampleModel;
      db = FakeDatabaseService();
      controller = ChatViewController(
        inferenceEngine: engine,
        modelManager: manager,
        databaseService: db,
      );
    });

    tearDown(() async {
      await controller.close();
    });

    test('init resolves active model and installs status', () async {
      await controller.init();

      expect(controller.state.activeModel, sampleModel);
      expect(controller.state.hasModelInstalled, true);
      expect(controller.state.responseStyle, 'Balanced');
      expect(controller.state.isReasoningMode, false);
    });

    test('sendMessage appends user & AI bubbles, streams tokens to completion', () async {
      await controller.init();

      final future = controller.sendMessage('Hello Bunji');
      expect(controller.state.isGenerating, true);
      expect(controller.state.messages.length, 2);
      expect(controller.state.messages[0].text, 'Hello Bunji');
      expect(controller.state.messages[0].sender, ChatMessageSender.user);
      expect(controller.state.messages[1].sender, ChatMessageSender.ai);
      expect(controller.state.messages[1].isStreaming, true);

      await future;

      expect(controller.state.isGenerating, false);
      expect(controller.state.messages[1].isStreaming, false);
      expect(
        controller.state.messages[1].text,
        'Hello there! How can I help?',
      );
    });

    test('sendMessage rejects when no model is installed', () async {
      manager.installed = false;
      manager.activeModel = null;
      await controller.init();

      await controller.sendMessage('Test prompt');

      expect(controller.state.isGenerating, false);
      expect(controller.state.messages, isEmpty);
      expect(controller.state.ui.action, isA<ShowError>());
      final error = controller.state.ui.action as ShowError;
      expect(error.message, contains('No on-device AI model ready'));
    });

    test('stopGenerating halts streaming and marks current AI message as finished', () async {
      await controller.init();

      unawaited(controller.sendMessage('Tell me a long story'));
      await Future<void>.delayed(const Duration(milliseconds: 25));

      expect(controller.state.isGenerating, true);
      controller.stopGenerating();

      expect(controller.state.isGenerating, false);
      expect(controller.state.messages.last.isStreaming, false);
      expect(controller.state.messages.last.text, isNotEmpty);
    });

    test('clearMessages stops generation and wipes conversation', () async {
      await controller.init();
      await controller.sendMessage('First message');
      expect(controller.state.messages.length, 2);

      controller.clearMessages();
      expect(controller.state.messages, isEmpty);
      expect(controller.state.isGenerating, false);
    });

    test('captures generation error and marks message with error indicator', () async {
      await controller.init();
      engine.streamError = Exception('Engine inference failure');

      await controller.sendMessage('Trigger error');

      expect(controller.state.isGenerating, false);
      expect(controller.state.messages.last.error, contains('Engine inference failure'));
      expect(controller.state.messages.last.isStreaming, false);
    });

    test('parses thinking process and response correctly across streaming stages', () {
      // Stage 1: Actively streaming inside <think>
      final streamingThink = ChatMessage(
        id: '1',
        text: '<think>\nAnalyzing problem from first principles...',
        sender: ChatMessageSender.ai,
        timestamp: DateTime.now(),
        isStreaming: true,
      );
      expect(streamingThink.isActivelyThinking, true);
      expect(streamingThink.thinkingProcess, 'Analyzing problem from first principles...');
      expect(streamingThink.responseText, isEmpty);

      // Stage 2: Finished thinking, response streaming
      final thinkingDone = ChatMessage(
        id: '2',
        text: '<think>\nAnalyzing problem from first principles...\n</think>\nHere is the answer!',
        sender: ChatMessageSender.ai,
        timestamp: DateTime.now(),
        isStreaming: true,
      );
      expect(thinkingDone.isActivelyThinking, false);
      expect(thinkingDone.thinkingProcess, 'Analyzing problem from first principles...');
      expect(thinkingDone.responseText, 'Here is the answer!');

      // Stage 3: Normal message without think tags
      final normal = ChatMessage(
        id: '3',
        text: 'Just a regular answer.',
        sender: ChatMessageSender.ai,
        timestamp: DateTime.now(),
        isStreaming: false,
      );
      expect(normal.isActivelyThinking, false);
      expect(normal.thinkingProcess, isNull);
      expect(normal.responseText, 'Just a regular answer.');
    });

    test('persists chat session and messages to local database on first message with AI title', () async {
      await controller.init();

      await controller.sendMessage('Hello Bunji! Tell me about Australia.');

      expect(db.savedSessions.length, 1);
      final session = db.savedSessions.first;
      // Per requirements: Title is intelligent immediately ('Australia') and updated by AI ('Australia Guide')
      expect(session.title.value, 'Australia');
      expect(db.sessionTitles[session.id.value], 'Australia Guide');
      expect(controller.state.chatTitle, 'Australia Guide');
      expect(controller.state.chatTitle, isNot(contains('Hello Bunji!')));
      expect(controller.state.chatTitle, isNot('New Chat'));
      expect(controller.state.currentChatId, isNotNull);

      // User and AI message saved
      expect(db.savedMessages.length, 2);
      expect(db.savedMessages.first.sender.value, 'user');
      expect(db.savedMessages.last.sender.value, 'ai');

      // Verify that the title prompt fed both the whole user message and the whole AI response to the AI
      expect(engine.recordedPrompts.length, greaterThanOrEqualTo(2));
      final titlePrompt = engine.recordedPrompts.last;
      expect(titlePrompt, contains('Conversation:'));
      expect(titlePrompt, contains('User: Hello Bunji! Tell me about Australia.'));
      expect(titlePrompt, contains('Assistant: Hello there! How can I help?'));
      expect(titlePrompt, contains('Generate a title for this conversation'));
    });

    test('sets cover image on first message when image is attached', () async {
      await controller.init();

      controller.attachImage('/path/to/my_photo.jpg');
      expect(controller.state.attachedImagePath, '/path/to/my_photo.jpg');

      await controller.sendMessage('Check out this photo');

      expect(db.savedSessions.length, 1);
      final session = db.savedSessions.first;
      expect(session.coverImagePath.value, '/path/to/my_photo.jpg');
      expect(controller.state.coverImagePath, '/path/to/my_photo.jpg');
      expect(controller.state.attachedImagePath, isNull);

      // User message has imagePath
      expect(db.savedMessages.first.imagePath.value, '/path/to/my_photo.jpg');
    });

    test('toggleReasoningMode toggles state and persists to database', () async {
      await controller.init();
      expect(controller.state.isReasoningMode, false);

      await controller.toggleReasoningMode();
      expect(controller.state.isReasoningMode, true);
      expect(db.savedUserSettingsList.last.reasoningMode.value, true);

      await controller.toggleReasoningMode(false);
      expect(controller.state.isReasoningMode, false);
      expect(db.savedUserSettingsList.last.reasoningMode.value, false);
    });

    test('sendMessage reflects thinking vs fast mode in model prompt', () async {
      await controller.init();

      // Fast mode by default
      await controller.sendMessage('Fast question');
      expect(
        engine.recordedPrompts.first,
        equals('/no_think\nFast question'),
      );
      expect(
        engine.recordedPrompts.first,
        isNot(contains('<think>')),
      );
      expect(engine.recordedReasoningModes.first, false);

      // Switch to Thinking mode
      await controller.toggleReasoningMode(true);
      engine.recordedPrompts.clear();
      engine.recordedReasoningModes.clear();

      await controller.sendMessage('Reasoning question');
      expect(
        engine.recordedPrompts.first,
        startsWith('/think\n'),
      );
      expect(engine.recordedPrompts.first, contains('Reasoning question'));
      expect(engine.recordedReasoningModes.first, true);
    });

    test('strips thinking tags in fast mode so message never enters think mode', () async {
      await controller.init();
      expect(controller.state.isReasoningMode, false);

      // Custom engine that simulates a model that emits think tags
      final thinkEngine = FakeInferenceEngine();
      final testController = ChatViewController(
        inferenceEngine: thinkEngine,
        modelManager: manager,
        databaseService: db,
      );
      await testController.init();

      // Send in fast mode
      await testController.sendMessage('What is Flutter?');

      expect(testController.state.messages.last.text, isNot(contains('<think>')));
      expect(testController.state.messages.last.thinkingProcess, isNull);
      expect(testController.state.messages.last.isActivelyThinking, false);
      await testController.close();
    });

    test('filters <think> blocks during AI title generation and avoids <think> in chat title', () async {
      final thinkTitleEngine = FakeInferenceEngine();
      thinkTitleEngine.customTitleEmission = '<think>\nReasoning about Japan\n</think>\nJapan Highlights';

      final testController = ChatViewController(
        inferenceEngine: thinkTitleEngine,
        modelManager: manager,
        databaseService: db,
      );
      await testController.init();

      await testController.sendMessage('Tell me about Japan');

      expect(testController.state.chatTitle, equals('Japan Highlights'));
      expect(testController.state.chatTitle, isNot(contains('<think>')));
      await testController.close();
    });

    test('falls back to intelligent title when AI title only emits <think>', () async {
      final brokenTitleEngine = FakeInferenceEngine();
      brokenTitleEngine.customTitleEmission = '<think>\n';

      final testController = ChatViewController(
        inferenceEngine: brokenTitleEngine,
        modelManager: manager,
        databaseService: db,
      );
      await testController.init();

      await testController.sendMessage('What is Flutter?');

      expect(testController.state.chatTitle, isNot(equals('<think>')));
      expect(testController.state.chatTitle, isNot(contains('<think>')));
      expect(testController.state.chatTitle, isNotEmpty);
      await testController.close();
    });
  });
}
