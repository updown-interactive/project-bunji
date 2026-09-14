import 'package:bunji/shared/core/ui.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final UI ui;
  final String searchQuery;

  // AI & Models
  final String selectedModelId;
  final String responseStyle;
  final bool reasoningMode;
  final bool streamingResponses;

  // Privacy & Data
  final bool localAiOnly;
  final bool allowInternetForDownloads;
  final bool sendDiagnostics;
  final bool saveChatHistory;
  final String autoDeleteChats;
  final bool bunjiMemory;

  // Chat
  final bool enterToSend;
  final bool showAiIndicator;
  final bool autoScroll;
  final bool codeSyntaxHighlighting;
  final bool markdownRendering;
  final bool autoNameConversations;

  // Appearance
  final String themeMode; // 'System', 'Light', 'Dark'
  final String messageDensity; // 'Compact', 'Comfortable', 'Spacious'
  final bool reduceMotion;

  // Notifications
  final bool enableNotifications;
  final bool notifyTaskCompletion;
  final bool notifyDownloads;
  final bool notifyReminders;

  // App Behavior
  final String launchBehavior; // 'Open Home', 'Last Chat', 'New Chat'
  final bool hapticFeedback;
  final bool soundEffects;
  final bool confirmBeforeDeleting;

  // Language & Engine
  final String appLanguage;
  final String aiLanguage;
  final bool developerMode;

  const SettingsState({
    required this.ui,
    this.searchQuery = '',
    this.selectedModelId = 'qwen3_0_6b',
    this.responseStyle = 'Balanced',
    this.reasoningMode = false,
    this.streamingResponses = true,
    this.localAiOnly = true,
    this.allowInternetForDownloads = true,
    this.sendDiagnostics = false,
    this.saveChatHistory = true,
    this.autoDeleteChats = 'Never',
    this.bunjiMemory = true,
    this.enterToSend = true,
    this.showAiIndicator = true,
    this.autoScroll = true,
    this.codeSyntaxHighlighting = true,
    this.markdownRendering = true,
    this.autoNameConversations = true,
    this.themeMode = 'System',
    this.messageDensity = 'Comfortable',
    this.reduceMotion = false,
    this.enableNotifications = true,
    this.notifyTaskCompletion = true,
    this.notifyDownloads = true,
    this.notifyReminders = true,
    this.launchBehavior = 'Open Home',
    this.hapticFeedback = true,
    this.soundEffects = false,
    this.confirmBeforeDeleting = true,
    this.appLanguage = 'English (US)',
    this.aiLanguage = 'Auto-detect',
    this.developerMode = false,
  });

  const SettingsState.initial()
      : ui = const UI(),
        searchQuery = '',
        selectedModelId = 'qwen3_0_6b',
        responseStyle = 'Balanced',
        reasoningMode = false,
        streamingResponses = true,
        localAiOnly = true,
        allowInternetForDownloads = true,
        sendDiagnostics = false,
        saveChatHistory = true,
        autoDeleteChats = 'Never',
        bunjiMemory = true,
        enterToSend = true,
        showAiIndicator = true,
        autoScroll = true,
        codeSyntaxHighlighting = true,
        markdownRendering = true,
        autoNameConversations = true,
        themeMode = 'System',
        messageDensity = 'Comfortable',
        reduceMotion = false,
        enableNotifications = true,
        notifyTaskCompletion = true,
        notifyDownloads = true,
        notifyReminders = true,
        launchBehavior = 'Open Home',
        hapticFeedback = true,
        soundEffects = false,
        confirmBeforeDeleting = true,
        appLanguage = 'English (US)',
        aiLanguage = 'Auto-detect',
        developerMode = false;

  ThemeMode get flutterThemeMode {
    switch (themeMode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  SettingsState copyWith({
    UI? ui,
    String? searchQuery,
    String? selectedModelId,
    String? responseStyle,
    bool? reasoningMode,
    bool? streamingResponses,
    bool? localAiOnly,
    bool? allowInternetForDownloads,
    bool? sendDiagnostics,
    bool? saveChatHistory,
    String? autoDeleteChats,
    bool? bunjiMemory,
    bool? enterToSend,
    bool? showAiIndicator,
    bool? autoScroll,
    bool? codeSyntaxHighlighting,
    bool? markdownRendering,
    bool? autoNameConversations,
    String? themeMode,
    String? messageDensity,
    bool? reduceMotion,
    bool? enableNotifications,
    bool? notifyTaskCompletion,
    bool? notifyDownloads,
    bool? notifyReminders,
    String? launchBehavior,
    bool? hapticFeedback,
    bool? soundEffects,
    bool? confirmBeforeDeleting,
    String? appLanguage,
    String? aiLanguage,
    bool? developerMode,
  }) {
    return SettingsState(
      ui: ui ?? this.ui,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedModelId: selectedModelId ?? this.selectedModelId,
      responseStyle: responseStyle ?? this.responseStyle,
      reasoningMode: reasoningMode ?? this.reasoningMode,
      streamingResponses: streamingResponses ?? this.streamingResponses,
      localAiOnly: localAiOnly ?? this.localAiOnly,
      allowInternetForDownloads:
          allowInternetForDownloads ?? this.allowInternetForDownloads,
      sendDiagnostics: sendDiagnostics ?? this.sendDiagnostics,
      saveChatHistory: saveChatHistory ?? this.saveChatHistory,
      autoDeleteChats: autoDeleteChats ?? this.autoDeleteChats,
      bunjiMemory: bunjiMemory ?? this.bunjiMemory,
      enterToSend: enterToSend ?? this.enterToSend,
      showAiIndicator: showAiIndicator ?? this.showAiIndicator,
      autoScroll: autoScroll ?? this.autoScroll,
      codeSyntaxHighlighting:
          codeSyntaxHighlighting ?? this.codeSyntaxHighlighting,
      markdownRendering: markdownRendering ?? this.markdownRendering,
      autoNameConversations:
          autoNameConversations ?? this.autoNameConversations,
      themeMode: themeMode ?? this.themeMode,
      messageDensity: messageDensity ?? this.messageDensity,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      notifyTaskCompletion: notifyTaskCompletion ?? this.notifyTaskCompletion,
      notifyDownloads: notifyDownloads ?? this.notifyDownloads,
      notifyReminders: notifyReminders ?? this.notifyReminders,
      launchBehavior: launchBehavior ?? this.launchBehavior,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
      confirmBeforeDeleting:
          confirmBeforeDeleting ?? this.confirmBeforeDeleting,
      appLanguage: appLanguage ?? this.appLanguage,
      aiLanguage: aiLanguage ?? this.aiLanguage,
      developerMode: developerMode ?? this.developerMode,
    );
  }

  @override
  List<Object?> get props => [
        ui,
        searchQuery,
        selectedModelId,
        responseStyle,
        reasoningMode,
        streamingResponses,
        localAiOnly,
        allowInternetForDownloads,
        sendDiagnostics,
        saveChatHistory,
        autoDeleteChats,
        bunjiMemory,
        enterToSend,
        showAiIndicator,
        autoScroll,
        codeSyntaxHighlighting,
        markdownRendering,
        autoNameConversations,
        themeMode,
        messageDensity,
        reduceMotion,
        enableNotifications,
        notifyTaskCompletion,
        notifyDownloads,
        notifyReminders,
        launchBehavior,
        hapticFeedback,
        soundEffects,
        confirmBeforeDeleting,
        appLanguage,
        aiLanguage,
        developerMode,
      ];
}
