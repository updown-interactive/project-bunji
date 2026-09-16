import 'dart:async';
import 'package:bunji/app/di.dart';
import 'package:bunji/app/routes.dart';
import 'package:bunji/features/home/view/home_view.dart';
import 'package:bunji/features/home/model/tile_item.dart';
import 'package:bunji/features/home/viewcontroller/home_vc.dart';
import 'package:bunji/features/home/view/widgets/tile_card.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class FakeDatabaseService implements DatabaseService {
  List<ChatSession> currentSessions = [];
  Map<String, DbChatMessage> latestMessages = {};
  Map<String, DbChatMessage> latestAiMessages = {};
  Map<String, String> updatedTitles = {};

  @override
  Stream<List<ChatSession>> watchRecentChatSessions({int limit = 50}) =>
      Stream.value(currentSessions);

  @override
  Future<DbChatMessage?> getLatestChatMessage(String chatId) async {
    return latestMessages[chatId];
  }

  @override
  Future<DbChatMessage?> getLatestAiChatMessage(String chatId) async {
    return latestAiMessages[chatId] ?? latestMessages[chatId];
  }

  @override
  Future<void> updateChatSessionTitle(String id, String title) async {
    updatedTitles[id] = title;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestHomeViewController extends HomeViewController {
  TestHomeViewController({super.databaseService});

  void setItems(List<TileItem> items) {
    emit(state.copyWith(items: items));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeView & HomeViewController Chat Display Tests', () {
    late FakeDatabaseService db;

    setUp(() async {
      await sl.reset();
      db = FakeDatabaseService();
      sl.registerLazySingleton<DatabaseService>(() => db);
      sl.registerFactory<HomeViewController>(
          () => HomeViewController(databaseService: db));
    });

    tearDown(() async {
      await sl.reset();
    });

    test('HomeViewController converts stream of chat sessions into TileItems',
        () async {
      final session1 = ChatSession(
        id: 'session-1',
        title: 'Quantum Computing Intro',
        coverImagePath: null,
        modelId: 'qwen3_0_6b',
        isPinned: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      final session2 = ChatSession(
        id: 'session-2',
        title: 'Gourmet Pasta Ideas',
        coverImagePath: '/tmp/pasta.jpg',
        modelId: 'qwen3_0_6b',
        isPinned: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      db.currentSessions = [session1, session2];
      db.latestMessages['session-1'] = DbChatMessage(
        id: 'msg-1',
        chatId: 'session-1',
        content: 'Quantum bits can exist in superposition...',
        sender: 'assistant',
        timestamp: DateTime.now(),
        imagePath: null,
        error: null,
      );

      final controller = HomeViewController(databaseService: db);
      addTearDown(controller.close);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.items.length, equals(2));
      expect(controller.state.items[0].id, equals('session-1'));
      expect(controller.state.items[0].title, equals('Quantum Computing Intro'));
      expect(controller.state.items[0].isPinned, isTrue);
      expect(controller.state.items[0].content,
          equals('Quantum bits can exist in superposition...'));
      expect(controller.state.items[0].isFullBleed, isFalse);

      expect(controller.state.items[1].id, equals('session-2'));
      expect(controller.state.items[1].title, equals('Gourmet Pasta Ideas'));
      expect(controller.state.items[1].imageUrl, equals('/tmp/pasta.jpg'));
      expect(controller.state.items[1].timestamp, equals('Yesterday'));
      expect(controller.state.items[1].isFullBleed, isTrue);
    });

    test('Search filters chat sessions by title or message content', () async {
      final session1 = ChatSession(
        id: 'session-1',
        title: 'Morning Yoga Routine',
        coverImagePath: null,
        modelId: 'qwen',
        isPinned: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      db.currentSessions = [session1];
      db.latestMessages['session-1'] = DbChatMessage(
        id: 'msg-1',
        chatId: 'session-1',
        content: 'Start with 10 sun salutations',
        sender: 'assistant',
        timestamp: DateTime.now(),
        imagePath: null,
        error: null,
      );

      final controller = HomeViewController(databaseService: db);
      addTearDown(controller.close);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.filteredItems.length, equals(1));

      // Search matching title
      controller.updateSearchQuery('yoga');
      expect(controller.state.filteredItems.length, equals(1));

      // Search matching content snippet
      controller.updateSearchQuery('salutations');
      expect(controller.state.filteredItems.length, equals(1));

      // Search not matching
      controller.updateSearchQuery('astronomy');
      expect(controller.state.filteredItems, isEmpty);

      controller.cancelSearch();
      expect(controller.state.filteredItems.length, equals(1));
    });

    test('openChat dispatches NavigateTo with chatId', () {
      final controller = HomeViewController();
      addTearDown(controller.close);
      controller.openChat('session-abc');
      expect(controller.state.ui.action, isA<NavigateTo>());
      final action = controller.state.ui.action as NavigateTo;
      expect(action.route, equals(Routes.chat));
      expect(action.args, equals('session-abc'));
    });

    test('goToChat dispatches NavigateTo to chat route with null args', () {
      final controller = HomeViewController();
      addTearDown(controller.close);
      controller.goToChat();
      expect(controller.state.ui.action, isA<NavigateTo>());
      final action = controller.state.ui.action as NavigateTo;
      expect(action.route, equals(Routes.chat));
      expect(action.args, isNull);
    });

    testWidgets(
        'HomeView renders chat cards and tapping a card navigates to that chat session',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      String? openedChatId;

      final testController = HomeViewController(
        initialState: const HomeState(
          ui: UI(),
          items: [
            TileItem(
              id: 'chat-999',
              title: 'Trip to Kyoto Planning',
            ),
          ],
        ),
      );

      await sl.reset();
      sl.registerFactory<HomeViewController>(() => testController);

      final testRouter = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: Routes.chat.path,
            builder: (context, state) {
              openedChatId = state.extra as String?;
              return Scaffold(
                body: Text('Chat View for $openedChatId'),
              );
            },
          ),
          GoRoute(
            path: Routes.menu.path,
            builder: (context, state) => const Scaffold(body: Text('Menu')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: testRouter,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Trip to Kyoto Planning'), findsOneWidget);
      expect(find.byType(TileCard), findsOneWidget);

      // Tap on the chat card
      await tester.tap(find.text('Trip to Kyoto Planning'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(openedChatId, equals('chat-999'));
      expect(find.text('Chat View for chat-999'), findsOneWidget);
    });

    testWidgets('Empty state renders message when there are no conversations',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final testRouter = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: Routes.chat.path,
            builder: (context, state) =>
                const Scaffold(body: Text('Chat Screen')),
          ),
          GoRoute(
            path: Routes.menu.path,
            builder: (context, state) => const Scaffold(body: Text('Menu')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: testRouter,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No conversations yet'), findsOneWidget);
      expect(find.text('Start a conversation to see your chats here'),
          findsOneWidget);
    });

    test('replaces New Chat title with intelligent title and extracts first max 20 words of AI response',
        () async {
      final session = ChatSession(
        id: 'session-new-chat',
        title: 'New Chat',
        coverImagePath: null,
        modelId: 'qwen3_0_6b',
        isPinned: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      db.currentSessions = [session];
      db.latestMessages['session-new-chat'] = DbChatMessage(
        id: 'user-msg',
        chatId: 'session-new-chat',
        content: 'Tell me about Australia and Australian wildlife.',
        sender: 'user',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        imagePath: null,
        error: null,
      );

      // AI message with <think> tag and 35 words
      db.latestAiMessages['session-new-chat'] = DbChatMessage(
        id: 'ai-msg',
        chatId: 'session-new-chat',
        content:
            '<think>Thinking about unique Australian fauna and geography</think>'
            'Australia is home to unique animals like kangaroos, koalas, wallabies, platypuses, wombats, and echidnas. '
            'The continent features extraordinary biodiversity, vast deserts, and spectacular coral reefs along the coastline.',
        sender: 'ai',
        timestamp: DateTime.now(),
        imagePath: null,
        error: null,
      );

      final controller = HomeViewController(databaseService: db);
      addTearDown(controller.close);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.items.length, equals(1));
      final item = controller.state.items.first;

      // 1. Title must NOT be "New Chat", it must be intelligent
      expect(item.title, isNot('New Chat'));
      expect(item.title, contains('Australia'));
      // Database was updated with self-healed title
      expect(db.updatedTitles['session-new-chat'], isNotNull);
      expect(db.updatedTitles['session-new-chat'], isNot('New Chat'));

      // 2. Body snippet must NOT contain thinking process
      expect(item.content, isNotNull);
      expect(item.content, isNot(contains('<think>')));
      expect(item.content, isNot(contains('Thinking about unique')));

      // 3. Body snippet must be at most 20 words of the AI response
      final words = item.content!.replaceAll('...', '').split(' ').where((w) => w.isNotEmpty).toList();
      expect(words.length, lessThanOrEqualTo(20));
      expect(item.content, startsWith('Australia is home to unique animals'));
    });

    testWidgets('TileCard long press shows glass popup menu with Open Chat, Pin Conversation, and Delete Conversation',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool pinCalled = false;

      const testItem = TileItem(
        id: 'session-popup-test',
        title: 'Quantum Physics',
        timestamp: '10:30 AM',
        isPinned: false,
        content: 'Quantum physics explores particles at the subatomic scale.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TileCard(
                item: testItem,
                onTogglePin: () => pinCalled = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify card rendered
      expect(find.text('Quantum Physics'), findsOneWidget);

      // Long press card to open glass popup
      await tester.longPress(find.text('Quantum Physics'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify popup options exist
      expect(find.text('Open Chat'), findsOneWidget);
      expect(find.text('Pin Conversation'), findsOneWidget);
      expect(find.text('Delete Conversation'), findsOneWidget);

      // Tap Pin Conversation
      await tester.tap(find.text('Pin Conversation'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(pinCalled, isTrue);
    });
  });
}
