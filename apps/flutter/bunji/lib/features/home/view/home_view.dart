import 'package:bunji/app/di.dart';
import 'package:bunji/app/routes.dart';
import 'package:bunji/features/home/model/tile_item.dart';
import 'package:bunji/features/home/view/widgets/tile_card.dart';
import 'package:bunji/features/home/viewcontroller/home_vc.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (context) => sl<HomeViewController>(),
      child: BlocConsumer<HomeViewController, HomeState>(
        listener: (context, state) {
          final action = state.ui.action;
          if (action is NavigateTo) {
            if (action.replace) {
              context.go(action.route.path, extra: action.args);
            } else {
              context.push(action.route.path, extra: action.args).then((_) {
                if (context.mounted && action.route == Routes.menu) {
                  context.read<HomeViewController>().closeMenu();
                }
              });
            }
            context.read<HomeViewController>().clearAction();
          }
        },
        builder: (context, state) {
          final items = state.filteredItems;
          final leftColItems = <TileItem>[];
          final rightColItems = <TileItem>[];

          for (var i = 0; i < items.length; i++) {
            if (i.isEven) {
              leftColItems.add(items[i]);
            } else {
              rightColItems.add(items[i]);
            }
          }

          Widget content = Scaffold(
            body: SafeArea(
              child: GlassScaffold(
                bottomEdgeFade: true,
                extendBody: true,
                appBar: GlassAppBar(
                  leading: BunjiButton(
                    icon: const Icon(Icons.menu),
                    onTap: () {
                      context.read<HomeViewController>().goToMenu();
                    },
                  ),
                ),
                bottomBar: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    mainAxisAlignment: state.isSearching
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOutCubic,
                        width: state.isSearching ? sz.width - 48 : null,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: state.isSearching
                              ? GlassSearchBar(
                                  autofocus: true,
                                  key: const ValueKey('search'),
                                  onChanged: (value) {
                                    context
                                        .read<HomeViewController>()
                                        .updateSearchQuery(value);
                                  },
                                  showsCancelButton: true,
                                  onCancel: () {
                                    context
                                        .read<HomeViewController>()
                                        .cancelSearch();
                                  },
                                )
                              : BunjiButton(
                                  key: const ValueKey('search-button'),
                                  title: 'Search',
                                  icon: const Icon(Icons.search),
                                  onTap: () {
                                    context.read<HomeViewController>().search();
                                  },
                                ),
                        ),
                      ),
                      if (!state.isSearching) ...[
                        BunjiButton(
                          buttonColor: cs.primary,
                          title: 'Create',
                          icon: const Icon(Icons.create),
                          onTap: () {
                            context.read<HomeViewController>().goToChat();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                body: items.isEmpty
                    ? _buildEmptyState(context, state)
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column (Asymmetric offset to sit below top-left menu button)
                            Expanded(
                              child: Column(
                                children: [
                                  const SizedBox(height: 56),
                                  for (final item in leftColItems) ...[
                                    TileCard(
                                      item: item,
                                      onTap: () {
                                        context
                                            .read<HomeViewController>()
                                            .openChat(item.id);
                                      },
                                      onOpenChat: () {
                                        context
                                            .read<HomeViewController>()
                                            .openChat(item.id);
                                      },
                                      onTogglePin: () {
                                        context
                                            .read<HomeViewController>()
                                            .togglePin(item.id, item.isPinned);
                                      },
                                      onDeleteConversation: () {
                                        context
                                            .read<HomeViewController>()
                                            .deleteConversation(item.id);
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Right Column
                            Expanded(
                              child: Column(
                                children: [
                                  for (final item in rightColItems) ...[
                                    TileCard(
                                      item: item,
                                      onTap: () {
                                        context
                                            .read<HomeViewController>()
                                            .openChat(item.id);
                                      },
                                      onOpenChat: () {
                                        context
                                            .read<HomeViewController>()
                                            .openChat(item.id);
                                      },
                                      onTogglePin: () {
                                        context
                                            .read<HomeViewController>()
                                            .togglePin(item.id, item.isPinned);
                                      },
                                      onDeleteConversation: () {
                                        context
                                            .read<HomeViewController>()
                                            .deleteConversation(item.id);
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          );

          return content;
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeState state) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              state.isSearching
                  ? Icons.search_off_rounded
                  : Icons.chat_bubble_outline_rounded,
              size: 56,
              color: cs.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 14),
            Text(
              state.isSearching ? 'No items found' : 'No conversations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              state.isSearching
                  ? 'No results matching "${state.searchQuery}"'
                  : 'Start a conversation to see your chats here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
            ),
            if (!state.isSearching) ...[
              const SizedBox(height: 20),
              BunjiButton(
                title: 'Start Chat',
                icon: const Icon(Icons.create),
                buttonColor: cs.primary,
                onTap: () {
                  context.read<HomeViewController>().goToChat();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
