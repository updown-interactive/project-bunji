import 'package:bunji/features/home/model/tile_item.dart';
import 'package:flutter/material.dart';

/// An individual card widget designed to match the asymmetric tile layout.
class TileCard extends StatelessWidget {
  final TileItem item;
  final VoidCallback? onTap;

  const TileCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (item.isFullBleed && item.imageUrl != null) {
      return _buildFullBleedCard(context);
    }
    return _buildStandardCard(context);
  }

  Widget _buildStandardCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: .circular(44),
        border: .all(color: cs.outline.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(44),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Timestamp / Pin header
                if (item.timestamp != null || item.isPinned) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.isPinned) ...[
                        Icon(
                          Icons.push_pin_rounded,
                          size: 13,
                          color: cs.onSurface.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (item.timestamp != null)
                        Text(
                          item.timestamp!,
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
                  item.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.4,
                    height: 1.22,
                  ),
                ),

                // Body snippet
                if (item.content != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    item.content!,
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
                if (item.imageUrl != null) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 1.1,
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: cs.surfaceContainer.withValues(alpha: 0.5),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
            onTap: onTap,
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 0.82,
                  child: Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade900,
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
                        color: Colors.grey.shade900,
                        child: const Icon(
                          Icons.broken_image_rounded,
                          color: Colors.white38,
                        ),
                      );
                    },
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
                      if (item.timestamp != null) ...[
                        Text(
                          item.timestamp!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        item.title,
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
}
