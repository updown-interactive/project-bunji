import 'dart:io';
import 'package:bunji/app/di.dart';
import 'package:bunji/app/routes.dart';
import 'package:bunji/shared/services/database/app_database.dart';
import 'package:bunji/shared/services/database/database_service.dart';
import 'package:bunji/shared/widgets/button.dart';
import 'package:bunji/shared/widgets/images.dart';
import 'package:bunji/shared/widgets/label.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final panelWidth = (sz.width * 0.78).clamp(280.0, 360.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // Overlay side panel on the left
          SizedBox(
            width: panelWidth,
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 8,
                            children: [
                              Label(
                                .bunji,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                    ),
                              ),
                              Images(.bunji, height: 30, width: 30),
                            ],
                          ),
                          BunjiButton(
                            height: 40,
                            width: 40,
                            icon: const Icon(Icons.close_rounded),
                            buttonColor: cs.primary.withValues(alpha: 0.5),
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              }
                            },
                          ),
                        ],
                      ),
                      Divider(
                        height: 12,
                        thickness: 0.5,
                        color: cs.outline.withValues(alpha: 0.2),
                      ),

                      //Menu Options Buttons
                      const SizedBox(height: 16),
                      MenuTile(apptext: .images, icon: Icons.image_outlined),
                      const SizedBox(height: 4),
                      MenuTile(
                        apptext: .models,
                        icon: Icons.psychology_outlined,
                        onTap: () => context.push(Routes.models.path),
                      ),
                      const SizedBox(height: 4),
                      MenuTile(apptext: .memory, icon: Icons.cached),
                      Divider(
                        height: 12,
                        thickness: 0.5,
                        color: cs.outline.withValues(alpha: 0.2),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Label(.pinned, style: tt.titleSmall),
                              const SizedBox(height: 4),
                              MenuTile(
                                text: "Release Notes Summary",
                                icon: Icons.chat_bubble_outline_rounded,
                                style: tt.bodySmall,
                              ),
                              const SizedBox(height: 16),
                              Label(.recents, style: tt.titleSmall),
                              const SizedBox(height: 4),
                              StreamBuilder<List<ChatSession>>(
                                stream: sl<DatabaseService>()
                                    .watchRecentChatSessions(limit: 10),
                                builder: (context, snapshot) {
                                  final sessions = snapshot.data ?? [];
                                  if (sessions.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        'No recent conversations yet',
                                        style: tt.bodySmall?.copyWith(
                                          color: cs.onSurface.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return Column(
                                    children: sessions.map((session) {
                                      final hasCover =
                                          session.coverImagePath != null &&
                                          File(
                                            session.coverImagePath!,
                                          ).existsSync();
                                      return MenuTile(
                                        leading: hasCover
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Image.file(
                                                  File(session.coverImagePath!),
                                                  width: 20,
                                                  height: 20,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : null,
                                        icon: hasCover
                                            ? null
                                            : Icons.chat_bubble_outline_rounded,
                                        text: session.title,
                                        onTap: () {
                                          if (context.canPop()) {
                                            context.pop();
                                          }
                                          context.push(
                                            Routes.chat.path,
                                            extra: session.id,
                                          );
                                        },
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      Divider(
                        height: 12,
                        thickness: 0.5,
                        color: cs.outline.withValues(alpha: 0.2),
                      ),

                      Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Row(
                              spacing: 8,
                              children: [
                                Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    Text('Person Name'),
                                    Text(
                                      'someone@gmail.com',
                                      style: tt.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Builder(
                            builder: (btnContext) {
                              return BunjiButton(
                                icon: const Icon(Icons.settings),
                                onTap: () => _showSettingsPopupMenu(btnContext),
                                buttonColor: cs.surfaceContainer,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Tap on right area to dismiss overlay
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsPopupMenu(BuildContext buttonContext) {
    final renderBox = buttonContext.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;
    final sz = MediaQuery.of(buttonContext).size;
    final cs = Theme.of(buttonContext).colorScheme;

    const popupWidth = 190.0;
    // Align right edge of popup with right edge of button, clamped within screen margins
    final popupLeft = (offset.dx + size.width - popupWidth).clamp(
      16.0,
      sz.width - popupWidth - 16.0,
    );
    final popupBottom = sz.height - offset.dy + 8.0;

    showGeneralDialog(
      context: buttonContext,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              left: popupLeft,
              bottom: popupBottom,
              child: Material(
                color: Colors.transparent,
                child: GlassContainer(
                  width: popupWidth,
                  shape: const LiquidRoundedSuperellipse(borderRadius: 40),
                  settings: LiquidGlassSettings(
                    glassColor: cs.surfaceContainer.withValues(alpha: 0.1),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPopupMenuItem(
                        context: dialogContext,
                        icon: Icons.person_outline_rounded,
                        title: 'Profile',
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          buttonContext.push(Routes.profile.path);
                        },
                      ),
                      _buildPopupMenuItem(
                        context: dialogContext,
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          buttonContext.push(Routes.settings.path);
                        },
                      ),
                      Divider(
                        height: 12,
                        thickness: 0.5,
                        color: cs.outline.withValues(alpha: 0.2),
                      ),
                      _buildPopupMenuItem(
                        context: dialogContext,
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        color: cs.error,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            alignment: Alignment.bottomRight,
            scale: Tween<double>(begin: 0.78, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildPopupMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final cs = Theme.of(context).colorScheme;
    final itemColor = color ?? cs.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: itemColor),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final Widget? leading;
  final IconData? icon;
  final AppText? apptext;
  final String? text;
  final TextStyle? style;
  final VoidCallback? onTap;
  const MenuTile({
    super.key,
    this.leading,
    this.icon,
    this.apptext,
    this.text,
    this.style,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 8),
            ] else if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            if (apptext != null) ...[
              Label(
                apptext,
                style: style ?? Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (text != null) ...[
              Expanded(
                child: Text(
                  text ?? "",
                  style: style ?? Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
