import 'dart:async';
import 'package:bunji/app/di.dart';
import 'package:bunji/app/routes.dart';
import 'package:bunji/features/chat/chat.dart';
import 'package:bunji/features/home/model/tile_item.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeState extends Equatable {
  final UI ui;
  final bool isSearching;
  final String searchQuery;
  final List<TileItem> items;
  final bool isMenuOpen;

  const HomeState({
    required this.ui,
    this.isSearching = false,
    this.searchQuery = '',
    this.items = const [],
    this.isMenuOpen = false,
  });

  const HomeState.initial()
      : ui = const UI(),
        isSearching = false,
        searchQuery = '',
        items = const [],
        isMenuOpen = false;

  List<TileItem> get filteredItems {
    if (searchQuery.trim().isEmpty) return items;
    final q = searchQuery.toLowerCase();
    return items.where((item) {
      final titleMatch = item.title.toLowerCase().contains(q);
      final contentMatch =
          item.content != null && item.content!.toLowerCase().contains(q);
      return titleMatch || contentMatch;
    }).toList();
  }

  HomeState copyWith({
    UI? ui,
    bool? isSearching,
    String? searchQuery,
    List<TileItem>? items,
    bool? isMenuOpen,
  }) {
    return HomeState(
      ui: ui ?? this.ui,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      items: items ?? this.items,
      isMenuOpen: isMenuOpen ?? this.isMenuOpen,
    );
  }

  @override
  List<Object?> get props => [ui, isSearching, searchQuery, items, isMenuOpen];
}

class HomeViewController extends Cubit<HomeState> {
  final DatabaseService? databaseService;
  StreamSubscription<List<ChatSession>>? _sessionsSub;

  HomeViewController({
    this.databaseService,
    HomeState? initialState,
  }) : super(initialState ?? const HomeState.initial()) {
    if (initialState == null) {
      _init();
    }
  }

  DatabaseService? get _db {
    if (databaseService != null) return databaseService;
    if (sl.isRegistered<DatabaseService>()) {
      return sl<DatabaseService>();
    }
    return null;
  }

  void _init() {
    final db = _db;
    if (db != null) {
      _sessionsSub = db.watchRecentChatSessions(limit: 50).listen(_onSessionsUpdated);
    }
  }

  Future<void> _onSessionsUpdated(List<ChatSession> sessions) async {
    if (isClosed) return;
    final db = _db;

    final newItems = await Future.wait(
      sessions.map((session) async {
        // Query latest AI message first; if none, query latest chat message
        final aiMsg = await db?.getLatestAiChatMessage(session.id);
        final latestMsg = aiMsg ?? await db?.getLatestChatMessage(session.id);

        // Body must be the first max 20 words of the AI response
        final snippet = ChatTitleHelper.extractAiSnippet(latestMsg?.content, maxWords: 20);
        final hasSnippet = snippet != null && snippet.isNotEmpty;
        final hasCover = session.coverImagePath != null &&
            session.coverImagePath!.isNotEmpty;

        // Ensure title is never "New Chat" on Home
        var displayTitle = session.title;
        if (displayTitle == 'New Chat' || displayTitle.trim().isEmpty) {
          final fallbackSource = await db?.getLatestChatMessage(session.id);
          displayTitle = ChatTitleHelper.createIntelligentTitle(fallbackSource?.content ?? '');
          // Self-heal the database record so it permanently updates
          unawaited(db?.updateChatSessionTitle(session.id, displayTitle));
        }

        return TileItem(
          id: session.id,
          title: displayTitle,
          timestamp: _formatTimestamp(session.updatedAt),
          isPinned: session.isPinned,
          content: hasSnippet ? snippet : null,
          imageUrl: hasCover ? session.coverImagePath : null,
          isFullBleed: hasCover && !hasSnippet,
        );
      }),
    );

    if (isClosed) return;
    emit(state.copyWith(items: newItems));
  }

  static String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0 && now.day == dt.day) {
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $ampm';
    } else if (diff.inDays <= 1 || (diff.inDays < 2 && now.day != dt.day)) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      return days[dt.weekday - 1];
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    }
  }

  void search() {
    emit(state.copyWith(isSearching: true));
  }

  void cancelSearch() {
    emit(state.copyWith(isSearching: false, searchQuery: ''));
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void openChat(String chatId) {
    emit(state.copyWith(
      ui: state.ui.navigateTo(Routes.chat, replace: false, args: chatId),
    ));
  }

  Future<void> deleteConversation(String chatId) async {
    await _db?.deleteChatSession(chatId);
  }

  Future<void> togglePin(String chatId, bool currentPinned) async {
    await _db?.updateChatSessionPin(chatId, !currentPinned);
  }

  void goToChat() {
    emit(state.copyWith(
      ui: state.ui.navigateTo(Routes.chat, replace: false, args: null),
    ));
  }

  void goToMenu() {
    emit(state.copyWith(
      isMenuOpen: true,
      ui: state.ui.navigateTo(Routes.menu, replace: false),
    ));
  }

  void closeMenu() {
    emit(state.copyWith(isMenuOpen: false));
  }

  void clearAction() {
    emit(state.copyWith(ui: state.ui.clearAction()));
  }

  @override
  Future<void> close() {
    _sessionsSub?.cancel();
    return super.close();
  }
}
