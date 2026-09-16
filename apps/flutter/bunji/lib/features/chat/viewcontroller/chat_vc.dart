import 'dart:async';
import 'dart:io';
import 'package:bunji/app/di.dart';
import 'package:bunji/shared/ai/services/bunji_inference_engine.dart';
import 'package:bunji/shared/ai/services/bunji_model_manager.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/services/database/app_database.dart';
import 'package:bunji/shared/services/database/database_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/chat_message.dart';
import '../util/chat_title_helper.dart';
import 'chat_state.dart';

class ChatViewController extends Cubit<ChatState> {
  final BunjiInferenceEngine? inferenceEngine;
  final BunjiModelManager? modelManager;
  final DatabaseService? databaseService;

  StreamSubscription<String>? _generationSubscription;
  StreamSubscription<dynamic>? _activeModelSubscription;

  ChatViewController({
    this.inferenceEngine,
    this.modelManager,
    this.databaseService,
  }) : super(const ChatState.initial());

  BunjiInferenceEngine get _engine =>
      inferenceEngine ?? sl<BunjiInferenceEngine>();
  BunjiModelManager get _manager =>
      modelManager ?? sl<BunjiModelManager>();
  DatabaseService get _db =>
      databaseService ?? sl<DatabaseService>();

  @override
  Future<void> close() {
    _generationSubscription?.cancel();
    _activeModelSubscription?.cancel();
    return super.close();
  }

  /// Initializes chat controller, active model state, and settings.
  Future<void> init() async {
    await _resolveActiveModel();

    // Watch for active model changes in database
    _activeModelSubscription?.cancel();
    _activeModelSubscription = _manager.watchActiveModel().listen((_) async {
      await _resolveActiveModel();
    });
  }

  Future<void> _resolveActiveModel() async {
    try {
      final active = await _manager.getActiveModel();
      final hasInstalled = await _manager.hasValidInstalledModel();

      // Ensure model is loaded into inference engine if on device
      if (active != null && !_engine.isModelLoaded) {
        final record = await _manager.getActiveInstalledModelRecord();
        if (record != null) {
          final file = File(record.filePath);
          if (await file.exists() && await file.length() > 0) {
            await _engine.loadModel(file);
          }
        }
      }

      // Check user preferences
      final settings = await _db.getUserSettings();

      emit(state.copyWith(
        activeModel: active,
        hasModelInstalled: hasInstalled,
        responseStyle: settings?.responseStyle ?? 'Balanced',
        isReasoningMode: settings?.reasoningMode ?? false,
      ));
    } catch (_) {
      // Graceful fallback
      emit(state.copyWith(
        hasModelInstalled: false,
      ));
    }
  }

  /// Attaches an image file from Camera or Photos to be sent with the next message.
  void attachImage(String path) {
    emit(state.copyWith(attachedImagePath: path));
  }

  /// Clears the currently attached image draft.
  void clearAttachedImage() {
    emit(state.copyWith(clearAttachedImage: true));
  }

  /// Starts a fresh chat session.
  void startNewChat() {
    stopGenerating();
    emit(state.copyWith(
      messages: [],
      clearChatId: true,
      clearChatTitle: true,
      clearCoverImage: true,
      clearAttachedImage: true,
    ));
  }

  /// Toggles or explicitly sets reasoning mode (Thinking mode vs Fast mode)
  /// and persists user preference to local database.
  Future<void> toggleReasoningMode([bool? value]) async {
    final nextMode = value ?? !state.isReasoningMode;
    emit(state.copyWith(isReasoningMode: nextMode));

    try {
      await _db.saveUserSettings(
        UserSettingsCompanion(
          id: const Value('default'),
          reasoningMode: Value(nextMode),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (_) {
      // Non-critical persistence failure in test/ephemeral setup
    }
  }

  /// Loads an existing conversation session from the local database.
  Future<void> loadChatSession(String chatId) async {
    stopGenerating();
    emit(state.copyWith(ui: state.ui.startLoading()));

    try {
      final session = await _db.getChatSession(chatId);
      final dbMessages = await _db.getChatMessages(chatId);

      final domainMessages = dbMessages.map(_fromDbMessage).toList();

      emit(state.copyWith(
        ui: state.ui.stopLoading(),
        messages: domainMessages,
        currentChatId: chatId,
        chatTitle: session?.title,
        coverImagePath: session?.coverImagePath,
        clearAttachedImage: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        ui: state.ui.showError('Failed to load chat: ${e.toString()}'),
      ));
    }
  }

  ChatMessage _fromDbMessage(DbChatMessage dbMsg) {
    return ChatMessage(
      id: dbMsg.id,
      text: dbMsg.content,
      sender: dbMsg.sender == 'user'
          ? ChatMessageSender.user
          : (dbMsg.sender == 'ai'
              ? ChatMessageSender.ai
              : ChatMessageSender.system),
      timestamp: dbMsg.timestamp,
      imagePath: dbMsg.imagePath,
      error: dbMsg.error,
    );
  }

  /// Sends a user message and streams the AI model response in real time.
  /// Automatically persists the chat session and messages to the local database.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    final attachedImage = state.attachedImagePath;

    if (trimmed.isEmpty && attachedImage == null) return;
    if (state.isGenerating) return;

    // Check if model is installed and ready
    if (!state.hasModelInstalled || state.activeModel == null) {
      emit(state.copyWith(
        ui: state.ui.showError(
          'No on-device AI model ready. Please download a model from Settings.',
        ),
      ));
      return;
    }

    final isFirstMessage = state.currentChatId == null;
    final chatId =
        state.currentChatId ?? 'chat_${DateTime.now().millisecondsSinceEpoch}';

    final userMessageId = '${DateTime.now().millisecondsSinceEpoch}_user';
    final aiMessageId = '${DateTime.now().millisecondsSinceEpoch}_ai';

    final messageText = trimmed.isNotEmpty ? trimmed : 'Shared an image';

    final userMessage = ChatMessage(
      id: userMessageId,
      text: messageText,
      sender: ChatMessageSender.user,
      timestamp: DateTime.now(),
      imagePath: attachedImage,
    );

    final aiMessage = ChatMessage(
      id: aiMessageId,
      text: '',
      sender: ChatMessageSender.ai,
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    if (isFirstMessage) {
      final initialTitle = ChatTitleHelper.createIntelligentTitle(trimmed);
      // Per requirements: cover image is used if the image was the first thing sent
      final coverImagePath = attachedImage;

      emit(state.copyWith(
        currentChatId: chatId,
        chatTitle: initialTitle,
        coverImagePath: coverImagePath,
        clearAttachedImage: true,
        messages: [...state.messages, userMessage, aiMessage],
        isGenerating: true,
      ));

      // Save initial chat session into the local database
      unawaited(_db.saveChatSession(
        ChatSessionsCompanion(
          id: Value(chatId),
          title: Value(initialTitle),
          coverImagePath: Value(coverImagePath),
          modelId: Value(state.activeModel?.id),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      ));
    } else {
      emit(state.copyWith(
        clearAttachedImage: true,
        messages: [...state.messages, userMessage, aiMessage],
        isGenerating: true,
      ));
    }

    // Persist user message to the local database
    unawaited(_db.saveChatMessage(
      ChatMessagesCompanion(
        id: Value(userMessageId),
        chatId: Value(chatId),
        content: Value(userMessage.text),
        sender: const Value('user'),
        timestamp: Value(userMessage.timestamp),
        imagePath: Value(attachedImage),
      ),
    ));

    // Ensure model is loaded into the inference engine
    if (!_engine.isModelLoaded) {
      final record = await _manager.getActiveInstalledModelRecord();
      if (record != null) {
        final file = File(record.filePath);
        if (await file.exists() && await file.length() > 0) {
          await _engine.loadModel(file);
        }
      }
    }

    final tokenBuffer = StringBuffer();
    final completer = Completer<void>();

    // If text was empty but image was sent, construct prompt for the AI
    final basePrompt = trimmed.isNotEmpty
        ? trimmed
        : 'Please assist me with the image I just provided.';

    final promptToSend = state.isReasoningMode
        ? '/think\nThink step-by-step and write your internal reasoning process inside <think>...</think> tags before answering.\n\n$basePrompt'
        : '/no_think\n$basePrompt';

    _generationSubscription?.cancel();
    _generationSubscription = _engine
        .generateStream(promptToSend, isReasoning: state.isReasoningMode)
        .listen(
      (token) {
        tokenBuffer.write(token);
        final currentText = tokenBuffer.toString();
        final textToDisplay = !state.isReasoningMode
            ? _stripThinkingTags(currentText)
            : currentText;
        _updateMessageText(aiMessageId, textToDisplay, isStreaming: true);
      },
      onError: (e) async {
        final errorMsg = 'Generation failed: ${e.toString()}';
        _updateMessageError(aiMessageId, errorMsg);
        emit(state.copyWith(isGenerating: false));

        await _db.saveChatMessage(
          ChatMessagesCompanion(
            id: Value(aiMessageId),
            chatId: Value(chatId),
            content: const Value('Error generating response.'),
            sender: const Value('ai'),
            timestamp: Value(aiMessage.timestamp),
            error: Value(errorMsg),
          ),
        );

        if (!completer.isCompleted) completer.complete();
      },
      onDone: () async {
        final rawFinalText = tokenBuffer.toString().trim();
        final stripped = _stripThinkingTags(rawFinalText, stripUnclosed: true).trim();
        final finalText = !state.isReasoningMode ? stripped : rawFinalText;
        final effectiveText = finalText.isNotEmpty
            ? finalText
            : (rawFinalText.isNotEmpty && !state.isReasoningMode
                ? rawFinalText.replaceAll(RegExp(r'<\/?think>', caseSensitive: false), '').trim()
                : 'Bunji was unable to generate a response. Please try again.');

        if (!isClosed) {
          _updateMessageText(
            aiMessageId,
            effectiveText,
            isStreaming: false,
          );
          emit(state.copyWith(isGenerating: false));
        }

        // Persist AI response message to the local database
        await _db.saveChatMessage(
          ChatMessagesCompanion(
            id: Value(aiMessageId),
            chatId: Value(chatId),
            content: Value(effectiveText),
            sender: const Value('ai'),
            timestamp: Value(aiMessage.timestamp),
          ),
        );

        // Update session's last updated timestamp
        final currentTitle = state.chatTitle ??
            ChatTitleHelper.createIntelligentTitle(messageText);
        await _db.updateChatSessionTitle(chatId, currentTitle);

        // Generate an intelligent title with AI using the full user message and full AI response
        final shouldGenerateTitle = isFirstMessage ||
            state.chatTitle == null ||
            state.chatTitle == 'Conversation' ||
            state.chatTitle == 'New Chat';

        if (shouldGenerateTitle) {
          await _generateTitleWithAi(
            chatId,
            messageText,
            responseSummary: effectiveText,
          );
        }

        if (!completer.isCompleted) completer.complete();
      },
      cancelOnError: true,
    );

    return completer.future;
  }

  /// Generates a title using the AI model from the user message and AI response.
  Future<void> _generateTitleWithAi(
    String chatId,
    String promptText, {
    String? responseSummary,
  }) async {
    try {
      final safeUserText = promptText.trim().isNotEmpty
          ? promptText.trim()
          : 'User sent an image';
      // Truncate user text to keep title prompt lightweight and fast to evaluate on-device
      final truncatedUser = safeUserText.length > 150
          ? '${safeUserText.substring(0, 150)}...'
          : safeUserText;

      // Strip <think> tags from AI response and truncate so on-device prompt evaluation is fast
      final thinkRegex =
          RegExp(r'<think>[\s\S]*?(?:<\/think>|$)', caseSensitive: false);
      final cleanAiResponse =
          (responseSummary ?? '').replaceAll(thinkRegex, '').trim();
      final truncatedAi = cleanAiResponse.length > 200
          ? '${cleanAiResponse.substring(0, 200)}...'
          : cleanAiResponse;

      final titlePrompt =
          '/no_think\nConversation:\n'
          'User: $truncatedUser\n'
          'Assistant: $truncatedAi\n\n'
          'Generate a title for this conversation. Respond with only a 3 to 5 word title, no quotes, no reasoning, no <think> tags.\n'
          'Title:';

      final buffer = StringBuffer();
      final stream = _engine
          .generateStream(titlePrompt, isReasoning: false)
          .timeout(const Duration(seconds: 10));

      await for (final token in stream) {
        buffer.write(token);
        final current = buffer.toString();
        // If the model emitted <think>, wait until it closes before looking for the title
        if (current.contains('<think>')) {
          if (current.contains('</think>')) {
            final afterThink = current.split('</think>').last.trim();
            if (afterThink.contains('\n') || afterThink.length >= 40) break;
          }
        } else {
          // If no think tag, break at newline or reasonable length
          if (current.contains('\n') || current.length >= 40) break;
        }
      }

      var raw = buffer.toString();
      // Completely strip any thinking blocks that the model generated
      raw = raw.replaceAll(thinkRegex, '').trim();
      // Remove any stray <think> or </think> remnants
      raw = raw.replaceAll(RegExp(r'<\/?think>', caseSensitive: false), '').trim();

      // If there are newlines, take the first non-empty line
      var generated = raw.split('\n').firstWhere(
            (line) => line.trim().isNotEmpty,
            orElse: () => '',
          ).trim();

      // Clean up common AI prefixes, markdown, quotes or trailing punctuation
      generated = generated
          .replaceAll(RegExp(r'^(Title\s*:\s*)', caseSensitive: false), '')
          .replaceAll(RegExp(r'[\r\n"`*#]+'), ' ')
          .replaceAll("'", '')
          .replaceAll(RegExp(r'[.!?:;]+$'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      // Validate that the generated title is valid and not just think tag remnants
      final isInvalidTitle = generated.isEmpty ||
          generated.toLowerCase() == 'think' ||
          generated.toLowerCase().contains('<think') ||
          generated.length < 2;

      if (!isInvalidTitle) {
        if (generated.length > 40) {
          generated = generated.substring(0, 40).trim();
        }

        // Always update database record so Home, Menu, and Chat views receive it
        await _db.updateChatSessionTitle(chatId, generated);

        if (!isClosed && state.currentChatId == chatId) {
          emit(state.copyWith(chatTitle: generated));
        }
      } else {
        // Fallback: use intelligent title helper
        final fallback = ChatTitleHelper.createIntelligentTitle(promptText);
        await _db.updateChatSessionTitle(chatId, fallback);
        if (!isClosed && state.currentChatId == chatId) {
          emit(state.copyWith(chatTitle: fallback));
        }
      }
    } catch (_) {
      // Fallback remains the initial intelligent title already stored
    }
  }

  void _updateMessageText(String id, String text, {required bool isStreaming}) {
    if (isClosed) return;
    final updated = state.messages.map((m) {
      if (m.id == id) {
        return m.copyWith(text: text, isStreaming: isStreaming);
      }
      return m;
    }).toList();

    emit(state.copyWith(messages: updated));
  }

  void _updateMessageError(String id, String error) {
    if (isClosed) return;
    final updated = state.messages.map((m) {
      if (m.id == id) {
        return m.copyWith(
          isStreaming: false,
          error: error,
          text: m.text.isNotEmpty ? m.text : 'Error generating response.',
        );
      }
      return m;
    }).toList();

    emit(state.copyWith(messages: updated));
  }

  /// Cancels the ongoing token generation stream.
  void stopGenerating() {
    _generationSubscription?.cancel();
    _generationSubscription = null;
    _engine.stopGeneration();

    final updated = state.messages.map((m) {
      if (m.isStreaming) {
        return m.copyWith(isStreaming: false);
      }
      return m;
    }).toList();

    emit(state.copyWith(
      messages: updated,
      isGenerating: false,
    ));
  }

  /// Clears conversation messages.
  void clearMessages() {
    stopGenerating();
    emit(state.copyWith(messages: []));
  }

  void clearAction() {
    emit(state.copyWith(ui: state.ui.clearAction()));
  }

  /// Removes `<think>` blocks. In streaming mode, only closed `<think>...</think>` blocks
  /// are stripped so unclosed tags don't blank out all progress tokens.
  String _stripThinkingTags(String input, {bool stripUnclosed = false}) {
    if (!input.contains('<think>')) return input;
    final closedRegex = RegExp(r'<think>[\s\S]*?<\/think>', caseSensitive: false);
    var stripped = input.replaceAll(closedRegex, '').trimLeft();
    if (stripUnclosed) {
      final unclosedRegex = RegExp(r'<think>[\s\S]*$', caseSensitive: false);
      stripped = stripped.replaceAll(unclosedRegex, '').trimLeft();
    }
    return stripped;
  }
}
