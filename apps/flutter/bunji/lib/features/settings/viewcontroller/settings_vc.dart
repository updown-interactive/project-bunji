import 'dart:async';
import 'package:bunji/app/di.dart';
import 'package:bunji/features/settings/viewcontroller/settings_state.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsViewController extends Cubit<SettingsState> {
  final DatabaseService _databaseService;
  StreamSubscription<UserSetting?>? _settingsSubscription;

  SettingsViewController({DatabaseService? databaseService})
      : _databaseService = databaseService ?? sl<DatabaseService>(),
        super(const SettingsState.initial());

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    return super.close();
  }

  /// Initializes settings from the local database and subscribes to changes.
  Future<void> init() async {
    try {
      final saved = await _databaseService.getUserSettings();
      if (saved != null) {
        _applySavedSettings(saved);
      } else {
        // Initialize default settings row in the database
        await _databaseService.saveUserSettings(
          UserSettingsCompanion(
            id: const Value('default'),
            themeMode: const Value('system'),
            messageDensity: const Value('comfortable'),
            activeModelId: const Value('qwen3_0_6b'),
            responseStyle: const Value('Balanced'),
            reasoningMode: const Value(false),
            streamingTokens: const Value(true),
            localAiOnly: const Value(true),
            allowInternetForDownloads: const Value(true),
            sendDiagnostics: const Value(false),
            saveChatHistory: const Value(true),
            autoDeleteChats: const Value('Never'),
            bunjiMemory: const Value(true),
            enterToSend: const Value(true),
            showAiIndicator: const Value(true),
            autoScroll: const Value(true),
            codeSyntaxHighlighting: const Value(true),
            markdownRendering: const Value(true),
            autoNameConversations: const Value(true),
            reduceMotion: const Value(false),
            enableNotifications: const Value(true),
            notifyTaskCompletion: const Value(true),
            notifyDownloads: const Value(true),
            notifyReminders: const Value(true),
            launchBehavior: const Value('Open Home'),
            hapticFeedback: const Value(true),
            soundEffects: const Value(false),
            confirmBeforeDeleting: const Value(true),
            appLanguage: const Value('en'),
            aiLanguage: const Value('auto'),
            developerMode: const Value(false),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      // Keep in sync with reactive stream
      await _settingsSubscription?.cancel();
      _settingsSubscription = _databaseService.watchUserSettings().listen((setting) {
        if (setting != null) {
          _applySavedSettings(setting);
        }
      });
    } catch (_) {
      // In-memory fallback if database is unavailable
    }
  }

  void _applySavedSettings(UserSetting s) {
    String formattedTheme = 'System';
    switch (s.themeMode.toLowerCase()) {
      case 'light':
        formattedTheme = 'Light';
        break;
      case 'dark':
        formattedTheme = 'Dark';
        break;
      default:
        formattedTheme = 'System';
        break;
    }

    String formattedDensity = 'Comfortable';
    switch (s.messageDensity.toLowerCase()) {
      case 'compact':
        formattedDensity = 'Compact';
        break;
      case 'spacious':
        formattedDensity = 'Spacious';
        break;
      default:
        formattedDensity = 'Comfortable';
        break;
    }

    emit(state.copyWith(
      themeMode: formattedTheme,
      messageDensity: formattedDensity,
      selectedModelId: s.activeModelId,
      responseStyle: s.responseStyle,
      reasoningMode: s.reasoningMode,
      streamingResponses: s.streamingTokens,
      localAiOnly: s.localAiOnly,
      allowInternetForDownloads: s.allowInternetForDownloads,
      sendDiagnostics: s.sendDiagnostics,
      saveChatHistory: s.saveChatHistory,
      autoDeleteChats: s.autoDeleteChats,
      bunjiMemory: s.bunjiMemory,
      enterToSend: s.enterToSend,
      showAiIndicator: s.showAiIndicator,
      autoScroll: s.autoScroll,
      codeSyntaxHighlighting: s.codeSyntaxHighlighting,
      markdownRendering: s.markdownRendering,
      autoNameConversations: s.autoNameConversations,
      reduceMotion: s.reduceMotion,
      enableNotifications: s.enableNotifications,
      notifyTaskCompletion: s.notifyTaskCompletion,
      notifyDownloads: s.notifyDownloads,
      notifyReminders: s.notifyReminders,
      launchBehavior: s.launchBehavior,
      hapticFeedback: s.hapticFeedback,
      soundEffects: s.soundEffects,
      confirmBeforeDeleting: s.confirmBeforeDeleting,
      developerMode: s.developerMode,
    ));
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query.trim()));
  }

  /// Switches the theme mode ('System', 'Light', 'Dark') and persists to SQLite.
  Future<void> updateThemeMode(String theme) async {
    emit(state.copyWith(themeMode: theme));
    await _persist(UserSettingsCompanion(
      themeMode: Value(theme.toLowerCase()),
    ));
  }

  Future<void> updateMessageDensity(String density) async {
    emit(state.copyWith(messageDensity: density));
    await _persist(UserSettingsCompanion(
      messageDensity: Value(density.toLowerCase()),
    ));
  }

  Future<void> updateSelectedModel(String modelId) async {
    emit(state.copyWith(selectedModelId: modelId));
    await _persist(UserSettingsCompanion(
      activeModelId: Value(modelId),
    ));
    try {
      await _databaseService.setActiveAiModel(modelId);
    } catch (_) {}
  }

  Future<void> updateResponseStyle(String style) async {
    emit(state.copyWith(responseStyle: style));
    await _persist(UserSettingsCompanion(
      responseStyle: Value(style),
    ));
  }

  Future<void> toggleReasoningMode(bool value) async {
    emit(state.copyWith(reasoningMode: value));
    await _persist(UserSettingsCompanion(
      reasoningMode: Value(value),
    ));
  }

  Future<void> toggleStreamingResponses(bool value) async {
    emit(state.copyWith(streamingResponses: value));
    await _persist(UserSettingsCompanion(
      streamingTokens: Value(value),
    ));
  }

  Future<void> toggleLocalAiOnly(bool value) async {
    emit(state.copyWith(localAiOnly: value));
    await _persist(UserSettingsCompanion(
      localAiOnly: Value(value),
    ));
  }

  Future<void> toggleAllowInternetForDownloads(bool value) async {
    emit(state.copyWith(allowInternetForDownloads: value));
    await _persist(UserSettingsCompanion(
      allowInternetForDownloads: Value(value),
    ));
  }

  Future<void> toggleSendDiagnostics(bool value) async {
    emit(state.copyWith(sendDiagnostics: value));
    await _persist(UserSettingsCompanion(
      sendDiagnostics: Value(value),
    ));
  }

  Future<void> toggleSaveChatHistory(bool value) async {
    emit(state.copyWith(saveChatHistory: value));
    await _persist(UserSettingsCompanion(
      saveChatHistory: Value(value),
    ));
  }

  Future<void> updateAutoDeleteChats(String value) async {
    emit(state.copyWith(autoDeleteChats: value));
    await _persist(UserSettingsCompanion(
      autoDeleteChats: Value(value),
    ));
  }

  Future<void> toggleBunjiMemory(bool value) async {
    emit(state.copyWith(bunjiMemory: value));
    await _persist(UserSettingsCompanion(
      bunjiMemory: Value(value),
    ));
  }

  Future<void> toggleEnterToSend(bool value) async {
    emit(state.copyWith(enterToSend: value));
    await _persist(UserSettingsCompanion(
      enterToSend: Value(value),
    ));
  }

  Future<void> toggleShowAiIndicator(bool value) async {
    emit(state.copyWith(showAiIndicator: value));
    await _persist(UserSettingsCompanion(
      showAiIndicator: Value(value),
    ));
  }

  Future<void> toggleAutoScroll(bool value) async {
    emit(state.copyWith(autoScroll: value));
    await _persist(UserSettingsCompanion(
      autoScroll: Value(value),
    ));
  }

  Future<void> toggleCodeSyntaxHighlighting(bool value) async {
    emit(state.copyWith(codeSyntaxHighlighting: value));
    await _persist(UserSettingsCompanion(
      codeSyntaxHighlighting: Value(value),
    ));
  }

  Future<void> toggleMarkdownRendering(bool value) async {
    emit(state.copyWith(markdownRendering: value));
    await _persist(UserSettingsCompanion(
      markdownRendering: Value(value),
    ));
  }

  Future<void> toggleAutoNameConversations(bool value) async {
    emit(state.copyWith(autoNameConversations: value));
    await _persist(UserSettingsCompanion(
      autoNameConversations: Value(value),
    ));
  }

  Future<void> toggleReduceMotion(bool value) async {
    emit(state.copyWith(reduceMotion: value));
    await _persist(UserSettingsCompanion(
      reduceMotion: Value(value),
    ));
  }

  Future<void> toggleEnableNotifications(bool value) async {
    emit(state.copyWith(enableNotifications: value));
    await _persist(UserSettingsCompanion(
      enableNotifications: Value(value),
    ));
  }

  Future<void> toggleNotifyTaskCompletion(bool value) async {
    emit(state.copyWith(notifyTaskCompletion: value));
    await _persist(UserSettingsCompanion(
      notifyTaskCompletion: Value(value),
    ));
  }

  Future<void> toggleNotifyDownloads(bool value) async {
    emit(state.copyWith(notifyDownloads: value));
    await _persist(UserSettingsCompanion(
      notifyDownloads: Value(value),
    ));
  }

  Future<void> toggleNotifyReminders(bool value) async {
    emit(state.copyWith(notifyReminders: value));
    await _persist(UserSettingsCompanion(
      notifyReminders: Value(value),
    ));
  }

  Future<void> updateLaunchBehavior(String value) async {
    emit(state.copyWith(launchBehavior: value));
    await _persist(UserSettingsCompanion(
      launchBehavior: Value(value),
    ));
  }

  Future<void> toggleHapticFeedback(bool value) async {
    emit(state.copyWith(hapticFeedback: value));
    await _persist(UserSettingsCompanion(
      hapticFeedback: Value(value),
    ));
  }

  Future<void> toggleSoundEffects(bool value) async {
    emit(state.copyWith(soundEffects: value));
    await _persist(UserSettingsCompanion(
      soundEffects: Value(value),
    ));
  }

  Future<void> toggleConfirmBeforeDeleting(bool value) async {
    emit(state.copyWith(confirmBeforeDeleting: value));
    await _persist(UserSettingsCompanion(
      confirmBeforeDeleting: Value(value),
    ));
  }

  Future<void> toggleDeveloperMode(bool value) async {
    emit(state.copyWith(developerMode: value));
    await _persist(UserSettingsCompanion(
      developerMode: Value(value),
    ));
  }

  Future<void> _persist(UserSettingsCompanion update) async {
    try {
      final companion = update.copyWith(
        id: const Value('default'),
        updatedAt: Value(DateTime.now()),
      );
      await _databaseService.saveUserSettings(companion);
    } catch (_) {}
  }
}
