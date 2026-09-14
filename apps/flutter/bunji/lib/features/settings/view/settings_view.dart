import 'package:bunji/app/di.dart';
import 'package:bunji/app/routes.dart';
import 'package:bunji/features/settings/viewcontroller/settings_state.dart';
import 'package:bunji/features/settings/viewcontroller/settings_vc.dart';
import 'package:bunji/shared/widgets/button.dart';
import 'package:bunji/shared/widgets/label.dart';
import 'package:bunji/shared/widgets/theme_transition_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SettingsViewController>()..init(),
      child: const _SettingsViewContent(),
    );
  }
}

class _SettingsViewContent extends StatelessWidget {
  const _SettingsViewContent();

  bool _matchesQuery(String query, List<String> keywords) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return keywords.any((k) => k.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<SettingsViewController, SettingsState>(
      listener: (context, state) {},
      builder: (context, state) {
        final controller = context.read<SettingsViewController>();
        final q = state.searchQuery;

        return Scaffold(
          body: SafeArea(
            child: GlassScaffold(
              extendBody: true,
              bottomEdgeFade: true,
              appBar: GlassAppBar(
                title: Label(.settings),
                leading: BunjiButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(Routes.home.path);
                    }
                  },
                ),
              ),
              bottomBar: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: GlassSearchBar(onChanged: controller.updateSearchQuery),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 👤 Profile
                    if (_matchesQuery(q, [
                      'profile',
                      'siva',
                      'account',
                      'user',
                      'memory',
                      'personalization',
                    ]))
                      _buildProfileCard(context, controller, state, cs, tt),

                    // 2. 🧠 AI & Models (Most Prominent)
                    if (_matchesQuery(q, [
                      'ai',
                      'models',
                      'qwen',
                      'mobilellm',
                      'inference',
                      'creativity',
                      'reasoning',
                      'style',
                    ]))
                      _buildAiModelsCard(context, controller, state, cs, tt),

                    // 3. 🔒 Privacy & Data (Prominent)
                    if (_matchesQuery(q, [
                      'privacy',
                      'data',
                      'local ai',
                      'memory',
                      'history',
                      'delete',
                      'diagnostics',
                    ]))
                      _buildPrivacyDataCard(context, controller, state, cs, tt),

                    // 4. 💬 Chat
                    if (_matchesQuery(q, [
                      'chat',
                      'streaming',
                      'markdown',
                      'enter',
                      'syntax',
                      'scroll',
                      'conversation',
                    ]))
                      _buildChatCard(context, controller, state, cs, tt),

                    // 5. 🎨 Appearance (Theme Switching Logic)
                    if (_matchesQuery(q, [
                      'appearance',
                      'theme',
                      'dark',
                      'light',
                      'density',
                      'motion',
                      'accent',
                    ]))
                      _buildAppearanceCard(context, controller, state, cs, tt),

                    // 6. 🔔 Notifications
                    if (_matchesQuery(q, [
                      'notifications',
                      'alerts',
                      'reminders',
                      'tasks',
                      'downloads',
                    ]))
                      _buildNotificationsCard(
                        context,
                        controller,
                        state,
                        cs,
                        tt,
                      ),

                    // 7. 💾 Storage
                    if (_matchesQuery(q, [
                      'storage',
                      'cache',
                      'size',
                      'disk',
                      'models',
                      'clear',
                    ]))
                      _buildStorageCard(context, controller, state, cs, tt),

                    // 8. ⚙️ App Behavior
                    if (_matchesQuery(q, [
                      'app',
                      'behavior',
                      'launch',
                      'startup',
                      'haptic',
                      'sound',
                      'delete',
                    ]))
                      _buildAppBehaviorCard(context, controller, state, cs, tt),

                    // 9. 🌐 Language
                    if (_matchesQuery(q, [
                      'language',
                      'english',
                      'malayalam',
                      'hindi',
                      'voice',
                      'translate',
                    ]))
                      _buildLanguageCard(context, controller, state, cs, tt),

                    // 10. 🛠️ Advanced
                    if (_matchesQuery(q, [
                      'advanced',
                      'developer',
                      'cpu',
                      'gpu',
                      'metal',
                      'benchmark',
                      'diagnostics',
                    ]))
                      _buildAdvancedCard(context, controller, state, cs, tt),

                    // 11. ❓ Help & About
                    if (_matchesQuery(q, [
                      'help',
                      'about',
                      'version',
                      'license',
                      'updown',
                      'support',
                      'terms',
                    ]))
                      _buildHelpAboutCard(context, controller, state, cs, tt),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- SECTION BUILDERS ---

  // 1. 👤 Profile Card
  Widget _buildProfileCard(
    BuildContext context,
    SettingsViewController controller,
    SettingsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return _buildSectionCard(
      context: context,
      icon: Icons.person_outline_rounded,
      label: .profile,
      titleFallback: 'Profile',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Active',
          style: tt.labelSmall?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: cs.primary.withValues(alpha: 0.2),
              child: Text(
                'S',
                style: tt.titleLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Siva',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Personalization & local memory enabled',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
              onPressed: () {
                context.push(Routes.profile.path);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDivider(cs),
        _buildSwitchRow(
          title: 'Bunji Memory',
          subtitle: 'Remember personal facts, goals, and context across chats',
          value: state.bunjiMemory,
          onChanged: controller.toggleBunjiMemory,
          cs: cs,
          tt: tt,
        ),
      ],
    );
  }

  // 2. 🧠 AI & Models Card
  Widget _buildAiModelsCard(
    BuildContext context,
    SettingsViewController controller,
    SettingsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final models = [
      {
        'id': 'qwen3_0_6b',
        'name': 'Qwen3 0.6B',
        'tag': 'Recommended',
        'size': '494 MB',
        'desc':
            'Ultra fast, lightweight, and battery-friendly for everyday tasks',
      },
      {
        'id': 'mobilellm_r1_5_950m',
        'name': 'MobileLLM-R1.5 950M',
        'tag': 'Reasoning',
        'size': '620 MB',
        'desc':
            'Optimized for step-by-step logic, code, and structured analysis',
      },
      {
        'id': 'qwen3_1_7b',
        'name': 'Qwen3 1.7B',
        'tag': 'Deep Thinking',
        'size': '1.42 GB',
        'desc': 'Maximum intelligence, nuanced creative writing, and knowledge',
      },
    ];

    return _buildSectionCard(
      context: context,
      icon: Icons.psychology_outlined,
      label: .aiAndModels,
      titleFallback: 'AI & Models',
      isProminent: true,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'ON-DEVICE',
              style: tt.labelSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      children: [
        Text(
          'Active Model',
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // Model Cards
        ...models.map((m) {
          final isSelected = state.selectedModelId == m['id'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => controller.updateSelectedModel(m['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? cs.primary
                        : cs.outline.withValues(alpha: 0.15),
                    width: isSelected ? 1.5 : 0.5,
                  ),
                  color: isSelected
                      ? cs.primary.withValues(alpha: 0.08)
                      : cs.surface.withValues(alpha: 0.4),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected
                          ? cs.primary
                          : cs.onSurface.withValues(alpha: 0.4),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                m['name']!,
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  m['size']!,
                                  style: tt.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m['desc']!,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 8),
        _buildDivider(cs),

        // Response Style
        Text(
          'Response Style',
          style: tt.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        _buildSegmentedSelector<String>(
          options: const ['Balanced', 'Concise', 'Detailed'],
          selected: state.responseStyle,
          labelBuilder: (s) => s,
          onSelected: controller.updateResponseStyle,
          cs: cs,
          tt: tt,
        ),

        const SizedBox(height: 12),
        _buildSwitchRow(
          title: 'Reasoning Mode',
          subtitle:
              'Enable visible step-by-step thinking for analytical questions',
          value: state.reasoningMode,
          onChanged: controller.toggleReasoningMode,
          cs: cs,
          tt: tt,
        ),
        _buildSwitchRow(
          title: 'Streaming Tokens',
          subtitle:
              'Show words immediately as the neural network generates them',
          value: state.streamingResponses,
          onChanged: controller.toggleStreamingResponses,
          cs: cs,
          tt: tt,
        ),
      ],
    );
  }

  // 3. 🔒 Privacy & Data Card
  Widget _buildPrivacyDataCard(
    BuildContext context,
    SettingsViewController controller,
    SettingsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return _buildSectionCard(
      context: context,
      icon: Icons.shield_outlined,
      label: .privacyAndData,
      titleFallback: 'Privacy & Data',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '100% PRIVATE',
          style: tt.labelSmall?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      children: [
        // Privacy Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_rounded, color: Colors.green, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI runs 100% locally on your device. Your conversations and memories never leave your phone.',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.8),
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildSwitchRow(
          title: 'Local AI Only',
          subtitle: 'Disallow any external cloud fallback',
          value: state.localAiOnly,
          onChanged: controller.toggleLocalAiOnly,
          cs: cs,
          tt: tt,
        ),
        _buildSwitchRow(
          title: 'Allow Internet for Downloads',
          subtitle: 'Required only when fetching new offline GGUF models',
          value: state.allowInternetForDownloads,
          onChanged: controller.toggleAllowInternetForDownloads,
          cs: cs,
          tt: tt,
        ),
        _buildSwitchRow(
          title: 'Send Diagnostic Data',
          subtitle: 'Disabled by default. Help improve Bunji crash detection',
          value: state.sendDiagnostics,
          onChanged: controller.toggleSendDiagnostics,
          cs: cs,
          tt: tt,
        ),
        _buildSwitchRow(
          title: 'Save Chat History',
          subtitle: 'Keep conversations encrypted in local SQLite database',
          value: state.saveChatHistory,
          onChanged: controller.toggleSaveChatHistory,
          cs: cs,
          tt: tt,
        ),
        const SizedBox(height: 8),
        _buildDivider(cs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Auto-delete Chats',
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
            DropdownButton<String>(
              value: state.autoDeleteChats,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: cs.onSurface),
              dropdownColor: cs.surfaceContainerHighest,
              style: tt.bodySmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
              items: const [
                DropdownMenuItem(value: 'Never', child: Text('Never')),
                DropdownMenuItem(
                  value: 'After 30 days',
                  child: Text('After 30 days'),
                ),
                DropdownMenuItem(
                  value: 'After 90 days',
                  child: Text('After 90 days'),
                ),
              ],
              onChanged: (val) {
                if (val != null) controller.updateAutoDeleteChats(val);
              },
            ),
          ],
        ),
      ],
    );
  }

  // 4. 💬 Chat Card
  Widget _buildChatCard(
    BuildContext context,
    SettingsViewController controller,
    SettingsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return _buildSectionCard(
      context: context,
      icon: Icons.chat_bubble_outline_rounded,
      label: .chat,
      titleFallback: 'Chat',
      children: [
        _buildSwitchRow(
          title: 'Enter to Send',
          subtitle: 'Press Enter on keyboard to immediately dispatch prompt',
          value: state.enterToSend,
          onChanged: controller.toggleEnterToSend,
          cs: cs,
          tt: tt,
        ),
        _buildSwitchRow(
          title: 'Show AI Generation Indicator',
          subtitle:
              'Visual pulse animation while token generation is in flight',
          value: state.showAiIndicator,
          onChanged: controller.toggleShowAiIndicator,
          cs: cs,
          tt: tt,
        ),
        _buildSwitchRow(
          title: 'Auto-scroll to Bottom',
          subtitle:
              'Smoothly scroll the conversation viewport with incoming text',
          value: state.autoScroll,
          onChanged: controller.toggleAutoScroll,
          cs: cs,
          tt: tt,
        ),
        _buildSwitchRow(
          title: 'Code Syntax Highlighting',
          subtitle: 'Format Python, JavaScript, Dart and shell snippets',
          value: state.codeSyntaxHighlighting,
          onChanged: controller.toggleCodeSyntaxHighlighting,
          cs: cs,
          tt: tt,
        ),
        _buildSwitchRow(
          title: 'Markdown Rendering',
          subtitle: 'Render tables, lists, bold text, and math equations',
          value: state.markdownRendering,
          onChanged: controller.toggleMarkdownRendering,
          cs: cs,
          tt: tt,
        ),
        _buildSwitchRow(
          title: 'Automatically Name Chats',
          subtitle: 'Generate intelligent chat title from first user message',
          value: state.autoNameConversations,
          onChanged: controller.toggleAutoNameConversations,
          cs: cs,
          tt: tt,
        ),
      ],
    );
  }

  // 5. 🎨 Appearance Card (Wires in Theme Mode switching logic)
  Widget _buildAppearanceCard(
    BuildContext context,
    SettingsViewController controller,
    SettingsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return _buildSectionCard(
      context: context,
      icon: Icons.palette_outlined,
      label: .appearance,
      titleFallback: 'Appearance',
      children: [
        Text(
          'Theme Mode',
          style: tt.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        _buildThemeModeSelector(
          controller: controller,
          state: state,
          cs: cs,
          tt: tt,
        ),
        const SizedBox(height: 16),
        Text(
          'Message Density',
          style: tt.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        _buildSegmentedSelector<String>(
          options: const ['Compact', 'Comfortable', 'Spacious'],
          selected: state.messageDensity,
          labelBuilder: (s) => s,
          onSelected: controller.updateMessageDensity,
          cs: cs,
          tt: tt,
        ),
        const SizedBox(height: 12),
        _buildSwitchRow(
          title: 'Reduce Motion',
          subtitle:
              'Minimize interface transitions and liquid glass animations',
          value: state.reduceMotion,
          onChanged: controller.toggleReduceMotion,
          cs: cs,
          tt: tt,
        ),
      ],
    );
  }

  // 6. 🔔 Notifications Card
  Widget _buildNotificationsCard(
    BuildContext context,
    SettingsViewController controller,
    SettingsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return _buildSectionCard(
      context: context,
      icon: Icons.notifications_outlined,
      label: .notifications,
      titleFallback: 'Notifications',
      children: [
        _buildSwitchRow(
          title: 'Enable Notifications',
          subtitle: 'Allow Bunji to send local device notifications',
          value: state.enableNotifications,
          onChanged: controller.toggleEnableNotifications,
          cs: cs,
          tt: tt,
        ),
        if (state.enableNotifications) ...[
          _buildSwitchRow(
            title: 'AI Task Completion',
            subtitle: 'Notify when background processing or summaries finish',
            value: state.notifyTaskCompletion,
            onChanged: controller.toggleNotifyTaskCompletion,
            cs: cs,
            tt: tt,
          ),
          _buildSwitchRow(
            title: 'Model Downloads & Updates',
            subtitle: 'Alert when a new GGUF weights file finishes downloading',
            value: state.notifyDownloads,
            onChanged: controller.toggleNotifyDownloads,
            cs: cs,
            tt: tt,
          ),
          _buildSwitchRow(
            title: 'Reminders & Proactive Alerts',
            subtitle: 'Scheduled notifications requested during conversations',
            value: state.notifyReminders,
            onChanged: controller.toggleNotifyReminders,
            cs: cs,
            tt: tt,
          ),
        ],
      ],
    );
  }

  // 7. 💾 Storage Card
  Widget _buildStorageCard(
    BuildContext context,
    SettingsViewController controller,
    SettingsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return _buildSectionCard(
      context: context,
      icon: Icons.storage_outlined,
      label: .storage,
      titleFallback: 'Storage',
      trailing: Text(
        '1.85 GB Total',
        style: tt.labelMedium?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                Expanded(flex: 77, child: Container(color: cs.primary)),
                Expanded(flex: 5, child: Container(color: cs.secondary)),
                Expanded(flex: 7, child: Container(color: cs.tertiary)),
                Expanded(
                  flex: 11,
                  child: Container(color: cs.outline.withValues(alpha: 0.3)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildStorageRow('AI Models', '1.42 GB', cs.primary, cs, tt),
        _buildStorageRow(
          'Conversations & History',
          '84 MB',
          cs.secondary,
          cs,
          tt,
        ),
        _buildStorageRow('Cache & Temp Files', '126 MB', cs.tertiary, cs, tt),
        _buildStorageRow('App Executable & Base', '245 MB', cs.outline, cs, tt),
        const SizedBox(height: 8),
        _buildDivider(cs),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.onSurface,
                  side: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.cleaning_services_rounded, size: 18),
                label: const Text('Clear Cache'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache cleared (126 MB freed)'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.primary,
                  side: BorderSide(color: cs.primary.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.folder_open_rounded, size: 18),
                label: const Text('Manage Models'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 8. ⚙️ App Behavior Card
  Widget _buildAppBehaviorCard(
    BuildContext context,
    SettingsViewController controller,
    SettingsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return _buildSectionCard(
      context: context,
      icon: Icons.tune_rounded,
      label: .appBehavior,
      titleFallback: 'App Behavior',
      children: [
        Text(
          'Launch Behavior',
          style: tt.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        _buildSegmentedSelector<String>(
          options: const ['Open Home', 'Last Chat', 'New Chat'],
          selected: state.launchBehavior,
          labelBuilder: (s) => s,
          onSelected: controller.updateLaunchBehavior,
          cs: cs,
          tt: tt,
        ),
        const SizedBox(height: 12),
        _buildSwitchRow(
          title: 'Haptic Feedback',
          subtitle: 'Tactile vibrations on button taps and model responses',
          value: state.hapticFeedback,
          onChanged: controller.toggleHapticFeedback,
          cs: cs,
          tt: tt,
        ),
        _buildSwitchRow(
          title: 'Sound Effects',
          subtitle: 'Subtle audio cues on message arrival',
          value: state.soundEffects,
          onChanged: controller.toggleSoundEffects,
          cs: cs,
          tt: tt,
        ),
        _buildSwitchRow(
          title: 'Confirm Before Deleting',
          subtitle: 'Ask for confirmation when clearing chats or models',
          value: state.confirmBeforeDeleting,
          onChanged: controller.toggleConfirmBeforeDeleting,
          cs: cs,
          tt: tt,
        ),
      ],
    );
  }

  // 9. 🌐 Language Card
  Widget _buildLanguageCard(
    BuildContext context,
    SettingsViewController controller,
    SettingsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return _buildSectionCard(
      context: context,
      icon: Icons.language_rounded,
      label: .language,
      titleFallback: 'Language',
      children: [
        _buildInfoTile(
          title: 'App Interface Language',
          value: state.appLanguage,
          icon: Icons.translate_rounded,
          cs: cs,
          tt: tt,
        ),
        _buildDivider(cs),
        _buildInfoTile(
          title: 'AI Response Language',
          value: state.aiLanguage,
          icon: Icons.psychology_alt_outlined,
          cs: cs,
          tt: tt,
        ),
      ],
    );
  }

  // 10. 🛠️ Advanced Card
  Widget _buildAdvancedCard(
    BuildContext context,
    SettingsViewController controller,
    SettingsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return _buildSectionCard(
      context: context,
      icon: Icons.terminal_rounded,
      label: .advanced,
      titleFallback: 'Advanced',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Engine',
          style: tt.labelSmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      children: [
        _buildSwitchRow(
          title: 'Developer Mode',
          subtitle: 'Display tokens/sec, context window, and inference latency',
          value: state.developerMode,
          onChanged: controller.toggleDeveloperMode,
          cs: cs,
          tt: tt,
        ),
        _buildInfoTile(
          title: 'Hardware Acceleration',
          value: 'Metal / GPU Auto-accelerated',
          icon: Icons.speed_rounded,
          cs: cs,
          tt: tt,
        ),
        _buildInfoTile(
          title: 'CPU Threads',
          value: 'Auto (4 inference threads)',
          icon: Icons.memory_rounded,
          cs: cs,
          tt: tt,
        ),
      ],
    );
  }

  // 11. ❓ Help & About Card
  Widget _buildHelpAboutCard(
    BuildContext context,
    SettingsViewController controller,
    SettingsState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return _buildSectionCard(
      context: context,
      icon: Icons.help_outline_rounded,
      label: .helpAndAbout,
      titleFallback: 'Help & About',
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                color: cs.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bunji',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  'Version 1.0.0 (Build 100) • Local-first AI',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  'Made with care by Updown Interactive',
                  style: tt.bodySmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDivider(cs),
        _buildActionLink(
          'Terms of Service',
          Icons.description_outlined,
          cs,
          tt,
        ),
        _buildActionLink('Privacy Policy', Icons.privacy_tip_outlined, cs, tt),
        _buildActionLink('Report a Problem', Icons.bug_report_outlined, cs, tt),
      ],
    );
  }

  // --- REUSABLE COMPONENT HELPERS ---

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required AppText label,
    required String titleFallback,
    Widget? trailing,
    required List<Widget> children,
    bool isProminent = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isProminent
              ? cs.primary.withValues(alpha: 0.5)
              : cs.outline.withValues(alpha: 0.2),
          width: isProminent ? 1.0 : 0.5,
        ),
        color: cs.surfaceContainer,
        boxShadow: isProminent
            ? [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: isProminent ? cs.primary : cs.onSurface,
                    ),
                    Label(
                      label,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
                ?trailing,
              ],
            ),
            _buildDivider(cs),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ColorScheme cs) {
    return Divider(
      height: 18,
      thickness: 0.5,
      color: cs.outline.withValues(alpha: 0.2),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          GlassSwitch(
            thumbColor: cs.surfaceContainer,
            activeColor: cs.primary,
            inactiveColor: cs.surface,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedSelector<T>({
    required List<T> options,
    required T selected,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onSelected,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = opt == selected;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  labelBuilder(opt),
                  style: tt.labelSmall?.copyWith(
                    color: isSelected
                        ? cs.onPrimary
                        : cs.onSurface.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThemeModeSelector({
    required SettingsViewController controller,
    required SettingsState state,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    final themeOptions = [
      {
        'key': 'System',
        'label': 'System',
        'icon': Icons.brightness_auto_rounded,
      },
      {
        'key': 'Dark',
        'label': 'Dark',
        'icon': Icons.dark_mode_rounded,
      },
      {
        'key': 'Light',
        'label': 'Light',
        'icon': Icons.light_mode_rounded,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: themeOptions.map((opt) {
          final isSelected = opt['key'] == state.themeMode;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                ThemeTransitionCoordinator.tapOrigin = details.globalPosition;
              },
              onTap: () => controller.updateThemeMode(opt['key'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.onSurface.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(
                          color: cs.onSurface.withValues(alpha: 0.2),
                          width: 1,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6,
                  children: [
                    Icon(
                      opt['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? cs.onSurface
                          : cs.onSurface.withValues(alpha: 0.6),
                    ),
                    Text(
                      opt['label'] as String,
                      style: tt.labelSmall?.copyWith(
                        color: isSelected
                            ? cs.onSurface
                            : cs.onSurface.withValues(alpha: 0.6),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStorageRow(
    String title,
    String size,
    Color dotColor,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Text(
            size,
            style: tt.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  value,
                  style: tt.bodySmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionLink(
    String title,
    IconData icon,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
