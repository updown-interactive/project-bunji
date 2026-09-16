import 'dart:io';
import 'dart:math' as math;
import 'package:bunji/app/di.dart';
import 'package:bunji/app/routes.dart';
import 'package:bunji/features/chat/model/chat_message.dart';
import 'package:bunji/features/chat/viewcontroller/chat_state.dart';
import 'package:bunji/features/chat/viewcontroller/chat_vc.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:share_plus/share_plus.dart';

class ChatView extends StatelessWidget {
  final String? chatId;
  const ChatView({super.key, this.chatId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final vc = sl<ChatViewController>()..init();
        if (chatId != null) {
          vc.loadChatSession(chatId!);
        }
        return vc;
      },
      child: const _ChatViewContent(),
    );
  }
}

class _ChatViewContent extends StatefulWidget {
  const _ChatViewContent();

  @override
  State<_ChatViewContent> createState() => _ChatViewContentState();
}

class _ChatViewContentState extends State<_ChatViewContent>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 250),
          () => _scrollToBottom(),
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  void _handleSend(BuildContext context, ChatViewController controller) {
    final text = _textController.text.trim();
    if (text.isEmpty && controller.state.attachedImagePath == null) return;
    _textController.clear();
    controller.sendMessage(text);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  void _showAttachmentMenu(
    BuildContext buttonContext,
    ChatViewController controller,
  ) {
    final renderBox = buttonContext.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;
    final sz = MediaQuery.of(buttonContext).size;
    final cs = Theme.of(buttonContext).colorScheme;

    const popupWidth = 175.0;
    final popupLeft = (offset.dx + size.width - popupWidth).clamp(
      16.0,
      sz.width - popupWidth - 16.0,
    );
    final popupBottom = sz.height - offset.dy + 8.0;

    showGeneralDialog(
      context: buttonContext,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              left: popupLeft,
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
                      _buildAttachmentMenuItem(
                        context: dialogContext,
                        icon: Icons.camera_alt_outlined,
                        title: 'Camera',
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          _handleCameraAttachment(controller);
                        },
                      ),
                      _buildAttachmentMenuItem(
                        context: dialogContext,
                        icon: Icons.photo_library_outlined,
                        title: 'Photos',
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          _handlePhotosAttachment(controller);
                        },
                      ),
                      _buildAttachmentMenuItem(
                        context: dialogContext,
                        icon: Icons.folder_open_outlined,
                        title: 'Files',
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          _handleFilesAttachment();
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
            alignment: Alignment.bottomRight,
            scale: Tween<double>(begin: 0.78, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildAttachmentMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final itemColor = cs.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            GlassContainer(
              padding: .all(8),
              shape: const LiquidOval(),
              child: Icon(icon, size: 20, color: itemColor),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModelOptionsMenu(
    BuildContext buttonContext,
    ChatViewController controller,
    ChatState state,
  ) {
    final renderBox = buttonContext.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;
    final sz = MediaQuery.of(buttonContext).size;
    final cs = Theme.of(buttonContext).colorScheme;
    final tt = Theme.of(buttonContext).textTheme;

    const popupWidth = 264.0;
    final popupLeft = (offset.dx + size.width - popupWidth).clamp(
      16.0,
      sz.width - popupWidth - 16.0,
    );
    final popupTop = offset.dy + size.height + 8.0;

    showGeneralDialog(
      context: buttonContext,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Model Options',
      barrierColor: Colors.black.withValues(alpha: 0.18),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              left: popupLeft,
              top: popupTop,
              child: Material(
                color: Colors.transparent,
                child: GlassContainer(
                  width: popupWidth,
                  shape: const LiquidRoundedSuperellipse(borderRadius: 40),
                  settings: LiquidGlassSettings(
                    glassColor: cs.surfaceContainer.withValues(alpha: 0.4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Model Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.psychology_rounded,
                              size: 18,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.activeModel?.name ?? 'Bunji AI',
                                  style: tt.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  state.isReasoningMode
                                      ? 'Thinking Mode Active'
                                      : 'Fast Mode Active',
                                  style: tt.labelSmall?.copyWith(
                                    color: state.isReasoningMode
                                        ? cs.primary
                                        : Colors.amber.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: cs.outlineVariant.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'MODEL MODE',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Thinking Mode Option
                      _buildModeOption(
                        context: dialogContext,
                        icon: Icons.psychology_rounded,
                        iconColor: cs.primary,
                        title: 'Thinking Mode',
                        subtitle: 'Step-by-step reasoning (<think>)',
                        isSelected: state.isReasoningMode,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          controller.toggleReasoningMode(true);
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      const SizedBox(height: 6),
                      // Fast Mode Option
                      _buildModeOption(
                        context: dialogContext,
                        icon: Icons.bolt_rounded,
                        iconColor: Colors.amber.shade700,
                        title: 'Fast Mode',
                        subtitle: 'Direct, rapid generation',
                        isSelected: !state.isReasoningMode,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          controller.toggleReasoningMode(false);
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      const SizedBox(height: 10),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: cs.outlineVariant.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 6),
                      // Switch Model Option
                      _buildMenuActionTile(
                        context: dialogContext,
                        icon: Icons.tune_rounded,
                        title: 'Change Model',
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          context.push(Routes.models.path);
                        },
                      ),
                      // Clear Messages Option
                      _buildMenuActionTile(
                        context: dialogContext,
                        icon: Icons.delete_outline_rounded,
                        title: 'Clear Messages',
                        color: cs.error,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          controller.clearMessages();
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
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            alignment: Alignment.topRight,
            scale: Tween<double>(begin: 0.82, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildModeOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? cs.primary.withValues(alpha: 0.3)
                : cs.outlineVariant.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, size: 18, color: cs.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final effectiveColor = color ?? cs.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: effectiveColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: effectiveColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCameraAttachment(ChatViewController controller) async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null && mounted) {
        controller.attachImage(photo.path);
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _handlePhotosAttachment(ChatViewController controller) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        controller.attachImage(image.path);
      }
    } catch (e) {
      debugPrint('Photos error: $e');
    }
  }

  void _handleFilesAttachment() {
    // Attachment ready for files
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<ChatViewController, ChatState>(
      listener: (context, state) {
        final action = state.ui.action;
        if (action is ShowError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(action.message),
              backgroundColor: cs.error,
              action: !state.hasModelInstalled
                  ? SnackBarAction(
                      label: 'Settings',
                      textColor: cs.onError,
                      onPressed: () => context.push(Routes.settings.path),
                    )
                  : null,
            ),
          );
          context.read<ChatViewController>().clearAction();
        }

        // Auto-scroll on new message or update
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
      builder: (context, state) {
        final controller = context.read<ChatViewController>();
        final modelName = state.activeModel?.name ?? 'Bunji AI';

        return Scaffold(
          body: SafeArea(
            child: GlassScaffold(
              bottomEdgeFade: true,
              extendBody: true,
              appBar: GlassAppBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.coverImagePath != null &&
                        File(state.coverImagePath!).existsSync()) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(state.coverImagePath!),
                          width: 22,
                          height: 22,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        state.chatTitle ?? 'Conversation',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Builder(
                      builder: (actionBtnContext) {
                        return GlassContainer(
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 20,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          settings: LiquidGlassSettings(
                            glassColor: cs.surfaceContainer.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _showModelOptionsMenu(
                                actionBtnContext,
                                controller,
                                state,
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  state.isReasoningMode
                                      ? Icons.psychology_rounded
                                      : Icons.bolt_rounded,
                                  size: 16,
                                  color: state.isReasoningMode
                                      ? cs.primary
                                      : Colors.amber.shade700,
                                ),
                                const SizedBox(width: 6),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 120,
                                  ),
                                  child: Text(
                                    modelName,
                                    style: tt.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: cs.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              bottomBar: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!state.hasModelInstalled)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: cs.errorContainer.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cs.error.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.download_for_offline_outlined,
                              color: cs.onErrorContainer,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'No local model ready. Download one to start chatting.',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onErrorContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.push(Routes.settings.path),
                              style: TextButton.styleFrom(
                                foregroundColor: cs.onErrorContainer,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text('Download'),
                            ),
                          ],
                        ),
                      ),
                    if (state.attachedImagePath != null &&
                        File(state.attachedImagePath!).existsSync())
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: cs.primary.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                  image: DecorationImage(
                                    image: FileImage(
                                      File(state.attachedImagePath!),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: GestureDetector(
                                  onTap: controller.clearAttachedImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerHighest,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: cs.surface,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 12,
                      children: [
                        Expanded(
                          child: GlassTextField(
                            shape: const LiquidRoundedRectangle(
                              borderRadius: 38,
                            ),
                            controller: _textController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            placeholder: state.hasModelInstalled
                                ? 'Ask Bunji anything...'
                                : 'Download a model to chat...',
                            maxLines: 8,
                            minLines: 1,
                          ),
                        ),
                        if (state.isGenerating)
                          BunjiButton(
                            icon: const Icon(
                              Icons.stop_rounded,
                              color: Colors.white,
                            ),
                            buttonColor: cs.error,
                            onTap: controller.stopGenerating,
                          )
                        else
                          Builder(
                            builder: (btnContext) {
                              return BunjiButton(
                                icon: const Icon(Icons.arrow_upward_rounded),
                                buttonColor: state.hasModelInstalled
                                    ? cs.primary
                                    : cs.surfaceContainer.withValues(
                                        alpha: 0.4,
                                      ),
                                onLongPress: () {
                                  HapticFeedback.mediumImpact();
                                  _showAttachmentMenu(btnContext, controller);
                                },
                                onTap: () {
                                  if (!state.hasModelInstalled) {
                                    context.push(Routes.settings.path);
                                  } else {
                                    _handleSend(context, controller);
                                  }
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              body: state.messages.isEmpty
                  ? _buildEmptyState(context, controller, state)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 66, 20, 130),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final msg = state.messages[index];
                        if (msg.sender.isUser) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildUserMessage(
                              context,
                              message: msg.text,
                              time: _formatTime(msg.timestamp),
                              imagePath: msg.imagePath,
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildAiMessage(
                              context,
                              message: msg,
                              time: _formatTime(msg.timestamp),
                            ),
                          );
                        }
                      },
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ChatViewController controller,
    ChatState state,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 130),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'What can I help with?',
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            _buildSuggestions(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(ChatViewController controller) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final suggestions = [
      'How does on-device AI protect my privacy compared to cloud models?',
      'Summarize the core benefits of running local LLMs.',
      'Explain how quantized models run on mobile devices.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Suggested Prompts',
            style: tt.labelLarge?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...suggestions.map(
          (prompt) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => controller.sendMessage(prompt),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  prompt,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMessage(
    BuildContext context, {
    required String message,
    required String time,
    String? imagePath,
  }) {
    final cs = Theme.of(context).colorScheme;
    final maxW = MediaQuery.of(context).size.width * 0.78;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxW),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(6),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null && File(imagePath).existsSync()) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath),
                  width: maxW - 32,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              if (message.isNotEmpty && message != 'Shared an image')
                const SizedBox(height: 8),
            ],
            if (message.isNotEmpty &&
                (imagePath == null || message != 'Shared an image'))
              SelectableText(
                message,
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 15,
                  height: 1.38,
                ),
              ),
            const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                color: cs.onPrimary.withValues(alpha: 0.75),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiMessage(
    BuildContext context, {
    required ChatMessage message,
    required String time,
  }) {
    final cs = Theme.of(context).colorScheme;

    final thinking = message.thinkingProcess;
    final isActivelyThinking = message.isActivelyThinking;
    final responseText = message.responseText;

    final showThinkingBlock =
        (thinking != null && thinking.isNotEmpty) || isActivelyThinking;
    final hasResponseBody =
        responseText.isNotEmpty ||
        message.error != null ||
        (message.isStreaming && !showThinkingBlock);

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showThinkingBlock)
            Padding(
              padding: EdgeInsets.only(bottom: hasResponseBody ? 10 : 0),
              child: _ThinkingBlock(
                thinking: thinking ?? '',
                isActivelyThinking: isActivelyThinking,
                pulseAnimation: _pulseController,
              ),
            ),
          if (hasResponseBody)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: cs.outline.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.error != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.errorContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 16,
                            color: cs.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              message.error!,
                              style: TextStyle(
                                color: cs.onErrorContainer,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (responseText.isNotEmpty)
                    MarkdownBody(
                      data: message.isStreaming && !isActivelyThinking
                          ? '$responseText ▋'
                          : responseText,
                      selectable: true,
                      styleSheet: _buildMarkdownStyleSheet(context),
                    )
                  else if (message.isStreaming)
                    _PulsingBlip(animation: _pulseController),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (responseText.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _CopyActionButton(text: responseText),
                            const SizedBox(width: 2),
                            _ShareActionButton(text: responseText),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      Text(
                        time,
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return MarkdownStyleSheet(
      p: tt.bodyMedium?.copyWith(
        color: cs.onSurface,
        fontSize: 15,
        height: 1.45,
      ),
      h1: tt.titleLarge?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      h2: tt.titleMedium?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      h3: tt.titleSmall?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      h4: tt.bodyLarge?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.w600,
      ),
      em: const TextStyle(fontStyle: FontStyle.italic),
      strong: const TextStyle(fontWeight: FontWeight.bold),
      del: const TextStyle(decoration: TextDecoration.lineThrough),
      code: TextStyle(
        color: cs.primary,
        backgroundColor: cs.primary.withValues(alpha: 0.1),
        fontFamily: 'monospace',
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      ),
      codeblockDecoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      blockquoteDecoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: cs.primary.withValues(alpha: 0.7), width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      listBullet: tt.bodyMedium?.copyWith(
        color: cs.primary,
        fontWeight: FontWeight.bold,
      ),
      a: TextStyle(
        color: cs.primary,
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w500,
      ),
      tableBorder: TableBorder.all(
        color: cs.outlineVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      tableHead: tt.labelLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: cs.onSurface,
      ),
      tableBody: tt.bodyMedium?.copyWith(color: cs.onSurface),
    );
  }
}

/// Collapsible thinking/reasoning process widget.
class _ThinkingBlock extends StatefulWidget {
  final String thinking;
  final bool isActivelyThinking;
  final Animation<double> pulseAnimation;

  const _ThinkingBlock({
    required this.thinking,
    required this.isActivelyThinking,
    required this.pulseAnimation,
  });

  @override
  State<_ThinkingBlock> createState() => _ThinkingBlockState();
}

class _ThinkingBlockState extends State<_ThinkingBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _foldAnimation;
  late final Animation<double> _rotateAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _foldAnimation = Tween<double>(
      begin: -math.pi / 2.2,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _toggleExpand,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isActivelyThinking ? 'Thinking...' : 'Thought process',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                if (widget.isActivelyThinking) ...[
                  const SizedBox(width: 6),
                  FadeTransition(
                    opacity: widget.pulseAnimation,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
                Spacer(),
                RotationTransition(
                  turns: _rotateAnimation,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          alignment: Alignment.topCenter,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: AnimatedBuilder(
              animation: _foldAnimation,
              builder: (context, child) {
                final angle = _foldAnimation.value;
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.0018)
                  ..rotateX(angle);
                return Transform(
                  transform: transform,
                  alignment: Alignment.topCenter,
                  child: child,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: SelectableText.rich(
                    TextSpan(
                      text: widget.thinking,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.65),
                        fontSize: 12.5,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                      children: [
                        if (widget.isActivelyThinking)
                          WidgetSpan(
                            child: FadeTransition(
                              opacity: widget.pulseAnimation,
                              child: Text(
                                ' ▋',
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Action button that copies text to clipboard with animated checkmark feedback.
class _CopyActionButton extends StatefulWidget {
  final String text;

  const _CopyActionButton({required this.text});

  @override
  State<_CopyActionButton> createState() => _CopyActionButtonState();
}

class _CopyActionButtonState extends State<_CopyActionButton> {
  bool _copied = false;

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: _handleCopy,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _copied ? Icons.check_rounded : Icons.copy_rounded,
            key: ValueKey<bool>(_copied),
            size: 15,
            color: _copied ? cs.primary : cs.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}

/// Action button that invokes system share dialog.
class _ShareActionButton extends StatelessWidget {
  final String text;

  const _ShareActionButton({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        SharePlus.instance.share(ShareParams(text: text));
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(
          Icons.share_outlined,
          size: 15,
          color: cs.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

/// Animated pulsing blip shown after sending a message while the model is loading.
class _PulsingBlip extends StatelessWidget {
  final Animation<double> animation;

  const _PulsingBlip({required this.animation});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final scale = 0.8 + (t * 0.4);
        final glowOpacity = 0.25 + (t * 0.45);
        final coreOpacity = 0.65 + (t * 0.35);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main pulsing blip with halo
              Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                child: Container(
                  width: 9 * scale,
                  height: 9 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withValues(alpha: coreOpacity),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: glowOpacity),
                        blurRadius: 7 * scale,
                        spreadRadius: 1.5 * scale,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Secondary pulsing blip
              Container(
                width: 6 * (1.15 - (t * 0.3)),
                height: 6 * (1.15 - (t * 0.3)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withValues(alpha: 0.25 + ((1.0 - t) * 0.5)),
                ),
              ),
              const SizedBox(width: 5),
              // Tertiary pulsing blip
              Container(
                width: 4 * (0.85 + (t * 0.35)),
                height: 4 * (0.85 + (t * 0.35)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withValues(alpha: 0.2 + (t * 0.5)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
