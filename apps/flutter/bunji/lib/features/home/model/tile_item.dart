import 'package:equatable/equatable.dart';

/// Represents a card item in the asymmetric tile layout.
class TileItem extends Equatable {
  final String id;
  final String? timestamp;
  final bool isPinned;
  final String title;
  final String? content;
  final String? imageUrl;
  final bool isFullBleed;

  const TileItem({
    required this.id,
    required this.title,
    this.timestamp,
    this.isPinned = false,
    this.content,
    this.imageUrl,
    this.isFullBleed = false,
  });

  @override
  List<Object?> get props => [
        id,
        timestamp,
        isPinned,
        title,
        content,
        imageUrl,
        isFullBleed,
      ];
}
