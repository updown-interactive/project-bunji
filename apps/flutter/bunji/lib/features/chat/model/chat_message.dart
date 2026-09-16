import 'package:equatable/equatable.dart';

/// Semantic sender of a chat message.
enum ChatMessageSender {
  user,
  ai,
  system;

  bool get isUser => this == ChatMessageSender.user;
  bool get isAi => this == ChatMessageSender.ai;
  bool get isSystem => this == ChatMessageSender.system;
}

/// Representation of a single message in the Bunji on-device chat.
class ChatMessage extends Equatable {
  final String id;
  final String text;
  final ChatMessageSender sender;
  final DateTime timestamp;
  final bool isStreaming;
  final String? imagePath;
  final String? error;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isStreaming = false,
    this.imagePath,
    this.error,
  });

  /// Extracts reasoning text enclosed within `<think>...</think>` tags if present.
  String? get thinkingProcess {
    if (!text.contains('<think>')) return null;
    final startIndex = text.indexOf('<think>') + 7;
    final endIndex = text.indexOf('</think>');
    if (endIndex != -1) {
      return text.substring(startIndex, endIndex).trim();
    } else {
      // Actively streaming thinking block
      return text.substring(startIndex).trim();
    }
  }

  /// Whether the message is actively generating tokens inside an unclosed `<think>` tag.
  bool get isActivelyThinking {
    if (!text.contains('<think>')) return false;
    return !text.contains('</think>') && isStreaming;
  }

  /// The response text with `<think>...</think>` tags removed.
  String get responseText {
    if (!text.contains('<think>')) return text;
    final thinkRegex = RegExp(r'<think>[\s\S]*?(?:<\/think>|$)', caseSensitive: false);
    return text.replaceAll(thinkRegex, '').trimLeft();
  }

  ChatMessage copyWith({
    String? id,
    String? text,
    ChatMessageSender? sender,
    DateTime? timestamp,
    bool? isStreaming,
    String? imagePath,
    String? error,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      imagePath: imagePath ?? this.imagePath,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        sender,
        timestamp,
        isStreaming,
        imagePath,
        error,
      ];
}
