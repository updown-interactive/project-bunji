import 'package:drift/drift.dart';

/// Table definition for persisting user and application settings in Bunji.
class UserSettings extends Table {
  /// Unique identifier for the settings profile (e.g. 'default').
  TextColumn get id => text()();

  /// Theme mode: 'system', 'light', or 'dark'.
  TextColumn get themeMode => text().withDefault(const Constant('system'))();

  /// Message density: 'compact', 'comfortable', or 'spacious'.
  TextColumn get messageDensity =>
      text().withDefault(const Constant('comfortable'))();

  /// Active AI model identifier (e.g. 'qwen3_0_6b', 'mobilellm_r1_5_950m', 'qwen3_1_7b').
  TextColumn get activeModelId =>
      text().withDefault(const Constant('qwen3_0_6b'))();

  /// AI response style: 'Balanced', 'Concise', or 'Detailed'.
  TextColumn get responseStyle =>
      text().withDefault(const Constant('Balanced'))();

  /// Reasoning mode toggle (step-by-step thinking for analytical queries).
  BoolColumn get reasoningMode =>
      boolean().withDefault(const Constant(false))();

  /// Streaming responses toggle (render tokens dynamically).
  BoolColumn get streamingTokens =>
      boolean().withDefault(const Constant(true))();

  /// Local AI only toggle (strictly enforce 100% on-device inference).
  BoolColumn get localAiOnly => boolean().withDefault(const Constant(true))();

  /// Allow internet connectivity for model downloads.
  BoolColumn get allowInternetForDownloads =>
      boolean().withDefault(const Constant(true))();

  /// Send anonymous diagnostic data.
  BoolColumn get sendDiagnostics =>
      boolean().withDefault(const Constant(false))();

  /// Save chat history locally.
  BoolColumn get saveChatHistory =>
      boolean().withDefault(const Constant(true))();

  /// Auto-delete chats policy ('Never', 'After 30 days', 'After 90 days').
  TextColumn get autoDeleteChats =>
      text().withDefault(const Constant('Never'))();

  /// Bunji memory toggle (remembers facts across sessions).
  BoolColumn get bunjiMemory => boolean().withDefault(const Constant(true))();

  /// Enter key sends message.
  BoolColumn get enterToSend => boolean().withDefault(const Constant(true))();

  /// Show AI generation visual pulse indicator.
  BoolColumn get showAiIndicator =>
      boolean().withDefault(const Constant(true))();

  /// Auto-scroll conversation viewport to latest message.
  BoolColumn get autoScroll => boolean().withDefault(const Constant(true))();

  /// Code syntax highlighting in chat markdown.
  BoolColumn get codeSyntaxHighlighting =>
      boolean().withDefault(const Constant(true))();

  /// Markdown rich text rendering.
  BoolColumn get markdownRendering =>
      boolean().withDefault(const Constant(true))();

  /// Automatically generate conversation title from first user prompt.
  BoolColumn get autoNameConversations =>
      boolean().withDefault(const Constant(true))();

  /// Reduce motion and animations.
  BoolColumn get reduceMotion => boolean().withDefault(const Constant(false))();

  /// Enable master notifications.
  BoolColumn get enableNotifications =>
      boolean().withDefault(const Constant(true))();

  /// Notify on AI task completion.
  BoolColumn get notifyTaskCompletion =>
      boolean().withDefault(const Constant(true))();

  /// Notify on model download completion and updates.
  BoolColumn get notifyDownloads =>
      boolean().withDefault(const Constant(true))();

  /// Scheduled reminders and proactive alerts.
  BoolColumn get notifyReminders =>
      boolean().withDefault(const Constant(true))();

  /// App launch behavior ('Open Home', 'Last Chat', 'New Chat').
  TextColumn get launchBehavior =>
      text().withDefault(const Constant('Open Home'))();

  /// Haptic tactile feedback.
  BoolColumn get hapticFeedback =>
      boolean().withDefault(const Constant(true))();

  /// Subtle audio sound effects.
  BoolColumn get soundEffects =>
      boolean().withDefault(const Constant(false))();

  /// Confirmation dialog before deleting conversations or items.
  BoolColumn get confirmBeforeDeleting =>
      boolean().withDefault(const Constant(true))();

  /// App interface language.
  TextColumn get appLanguage => text().withDefault(const Constant('en'))();

  /// AI response language.
  TextColumn get aiLanguage => text().withDefault(const Constant('auto'))();

  /// Developer mode (displays latency, tokens/sec, and debug info).
  BoolColumn get developerMode =>
      boolean().withDefault(const Constant(false))();

  /// Timestamp of creation.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp of last update.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
