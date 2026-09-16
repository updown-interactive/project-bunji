import 'package:bunji/shared/ai/models/bunji_model.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:equatable/equatable.dart';
import '../model/chat_message.dart';

class ChatState extends Equatable {
  final UI ui;
  final List<ChatMessage> messages;
  final bool isGenerating;
  final BunjiModel? activeModel;
  final bool hasModelInstalled;
  final bool isReasoningMode;
  final String responseStyle;
  final String? currentChatId;
  final String? chatTitle;
  final String? coverImagePath;
  final String? attachedImagePath;

  const ChatState({
    required this.ui,
    this.messages = const [],
    this.isGenerating = false,
    this.activeModel,
    this.hasModelInstalled = true,
    this.isReasoningMode = false,
    this.responseStyle = 'Balanced',
    this.currentChatId,
    this.chatTitle,
    this.coverImagePath,
    this.attachedImagePath,
  });

  const ChatState.initial()
      : ui = const UI(),
        messages = const [],
        isGenerating = false,
        activeModel = null,
        hasModelInstalled = true,
        isReasoningMode = false,
        responseStyle = 'Balanced',
        currentChatId = null,
        chatTitle = null,
        coverImagePath = null,
        attachedImagePath = null;

  ChatState copyWith({
    UI? ui,
    List<ChatMessage>? messages,
    bool? isGenerating,
    BunjiModel? activeModel,
    bool clearActiveModel = false,
    bool? hasModelInstalled,
    bool? isReasoningMode,
    String? responseStyle,
    String? currentChatId,
    bool clearChatId = false,
    String? chatTitle,
    bool clearChatTitle = false,
    String? coverImagePath,
    bool clearCoverImage = false,
    String? attachedImagePath,
    bool clearAttachedImage = false,
  }) {
    return ChatState(
      ui: ui ?? this.ui,
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      activeModel: clearActiveModel ? null : (activeModel ?? this.activeModel),
      hasModelInstalled: hasModelInstalled ?? this.hasModelInstalled,
      isReasoningMode: isReasoningMode ?? this.isReasoningMode,
      responseStyle: responseStyle ?? this.responseStyle,
      currentChatId: clearChatId ? null : (currentChatId ?? this.currentChatId),
      chatTitle: clearChatTitle ? null : (chatTitle ?? this.chatTitle),
      coverImagePath:
          clearCoverImage ? null : (coverImagePath ?? this.coverImagePath),
      attachedImagePath: clearAttachedImage
          ? null
          : (attachedImagePath ?? this.attachedImagePath),
    );
  }

  @override
  List<Object?> get props => [
        ui,
        messages,
        isGenerating,
        activeModel,
        hasModelInstalled,
        isReasoningMode,
        responseStyle,
        currentChatId,
        chatTitle,
        coverImagePath,
        attachedImagePath,
      ];
}
