import 'dart:io';
import 'package:bunji/features/home/model/tile_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// An individual card widget designed to match the asymmetric tile layout.
class TileCard extends StatefulWidget {
  final TileItem item;
  final VoidCallback? onTap;
  final VoidCallback? onOpenChat;
  final VoidCallback? onDeleteConversation;
  final VoidCallback? onTogglePin;

  const TileCard({
    super.key,
    required this.item,
    this.onTap,
    this.onOpenChat,
    this.onDeleteConversation,
    this.onTogglePin,
  });

  @override
  State<TileCard> createState() => _TileCardState();
}

class _TileCardState extends State<TileCard> {
  Offset? _tapPosition;

  void _showGlassPopupMenu(BuildContext cardContext) {
    final renderBox = cardContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final sz = MediaQuery.of(cardContext).size;
    final cs = Theme.of(cardContext).colorScheme;

    const popupWidth = 205.0;
    const popupHeight = 165.0;

    final touchX = _tapPosition?.dx ?? (offset.dx + size.width / 2);
    final touchY = _tapPosition?.dy ?? (offset.dy + size.height / 2);

    final popupLeft = (touchX - popupWidth / 2).clamp(
      16.0,
      sz.width - popupWidth - 16.0,
    );
    final bool showBelow = touchY + popupHeight + 40 < sz.height;
    final double? popupTop = showBelow
        ? touchY.clamp(40.0, sz.height - popupHeight - 20.0)
        : null;
    final double? popupBottom = !showBelow
        ? (sz.height - touchY).clamp(40.0, sz.height - popupHeight - 20.0)
        : null;

    showGeneralDialog(
      context: cardContext,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              left: popupLeft,
              top: popupTop,
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
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Open Chat',
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          if (widget.onOpenChat != null) {
                            widget.onOpenChat!();
                          } else if (widget.onTap != null) {
                            widget.onTap!();
                          }
                        },
                      ),
                      _buildPopupMenuItem(
                        context: dialogContext,
                        icon: widget.item.isPinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        title: widget.item.isPinned
                            ? 'Unpin Conversation'
                            : 'Pin Conversation',
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          widget.onTogglePin?.call();
                        },
                      ),
                      Divider(
                        height: 12,
                        thickness: 0.5,
                        color: cs.outline.withValues(alpha: 0.2),
                      ),
                      _buildPopupMenuItem(
                        context: dialogContext,
                        icon: Icons.delete_outline_rounded,
                        title: 'Delete Conversation',
                        color: cs.error,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          widget.onDeleteConversation?.call();
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
            alignment: showBelow ? Alignment.topCenter : Alignment.bottomCenter,
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curved),
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
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: itemColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.isFullBleed && widget.item.imageUrl != null) {
      return _buildFullBleedCard(context);
    }
    return _buildStandardCard(context);
  }

  Widget _buildStandardCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(44),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(44),
        child: InkWell(
          onTapDown: (details) {
            _tapPosition = details.globalPosition;
          },
          onTap: widget.onTap ?? widget.onOpenChat,
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showGlassPopupMenu(context);
          },
          borderRadius: BorderRadius.circular(44),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Timestamp / Pin header
                if (widget.item.timestamp != null || widget.item.isPinned) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.item.isPinned) ...[
                        Icon(
                          Icons.push_pin_rounded,
                          size: 13,
                          color: cs.onSurface.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (widget.item.timestamp != null)
                        Text(
                          widget.item.timestamp!,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Title
                Text(
                  widget.item.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.4,
                    height: 1.22,
                  ),
                ),

                // Body snippet
                if (widget.item.content != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    widget.item.content!,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.55),
                      height: 1.36,
                    ),
                  ),
                ],

                // Embedded Image
                if (widget.item.imageUrl != null) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 1.1,
                      child: _buildTileImage(
                        context,
                        widget.item.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullBleedCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTapDown: (details) {
              _tapPosition = details.globalPosition;
            },
            onTap: widget.onTap ?? widget.onOpenChat,
            onLongPress: () {
              HapticFeedback.mediumImpact();
              _showGlassPopupMenu(context);
            },
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 0.82,
                  child: _buildTileImage(
                    context,
                    widget.item.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay for contrast
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                // Text Overlay
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.item.timestamp != null) ...[
                        Text(
                          widget.item.timestamp!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        widget.item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                          height: 1.22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTileImage(
    BuildContext context,
    String pathOrUrl, {
    required BoxFit fit,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isNetwork =
        pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://');

    if (isNetwork) {
      return Image.network(
        pathOrUrl,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: cs.surfaceContainer.withValues(alpha: 0.5),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: cs.surfaceContainer.withValues(alpha: 0.5),
            child: Icon(
              Icons.broken_image_rounded,
              color: cs.onSurface.withValues(alpha: 0.3),
            ),
          );
        },
      );
    }

    final file = File(pathOrUrl);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: cs.surfaceContainer.withValues(alpha: 0.5),
            child: Icon(
              Icons.broken_image_rounded,
              color: cs.onSurface.withValues(alpha: 0.3),
            ),
          );
        },
      );
    }

    return Container(
      color: cs.surfaceContainer.withValues(alpha: 0.5),
      child: Icon(
        Icons.image_not_supported_rounded,
        color: cs.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}
