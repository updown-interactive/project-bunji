import 'package:bunji/app/di.dart';
import 'package:bunji/app/routes.dart';
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
      items = _defaultItems,
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

  static const List<TileItem> _defaultItems = [
    TileItem(
      id: '1',
      timestamp: 'Monday',
      isPinned: true,
      title: 'Healthy\n30 Minute\nRecipes',
      content:
          'You can prepare a variety of healthy and satisfying meals in under 30 minutes by focus...',
    ),
    TileItem(
      id: '2',
      timestamp: '9:41 AM',
      title: 'Mexico City\nLargest Park',
      imageUrl:
          'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?q=80&w=600&auto=format&fit=crop',
    ),
    TileItem(
      id: '3',
      timestamp: '9:27 AM',
      title: 'Social Media\nLaunch\nEmail',
      content:
          'Here are a few ways you can present solutions to Aga, depending on how you\'d pre...',
    ),
    TileItem(
      id: '4',
      timestamp: '8:47 AM',
      title: 'History of\nMotion\nPictures',
      imageUrl:
          'https://images.unsplash.com/photo-1485846234645-a62644f84728?q=80&w=600&auto=format&fit=crop',
    ),
    TileItem(
      id: '5',
      timestamp: '8:14 AM',
      title: 'Chanterelle\nMushrooms',
      isFullBleed: true,
      imageUrl:
          'https://images.unsplash.com/photo-1546882200-a5df6ec17d6a?q=80&w=600&auto=format&fit=crop',
    ),
    TileItem(
      id: '6',
      timestamp: 'Yesterday',
      title: 'Rarest\nPigment\nExplanation',
      imageUrl:
          'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?q=80&w=600&auto=format&fit=crop',
    ),
  ];
}

class HomeViewController extends Cubit<HomeState> {
  final DatabaseService? databaseService;

  HomeViewController({this.databaseService}) : super(const HomeState.initial());

  DatabaseService get dbService => databaseService ?? sl<DatabaseService>();

  void search() {
    emit(state.copyWith(isSearching: true));
  }

  void cancelSearch() {
    emit(state.copyWith(isSearching: false, searchQuery: ''));
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void goToChat() {
    emit(state.copyWith(ui: state.ui.navigateTo(Routes.chat, replace: false)));
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
}
