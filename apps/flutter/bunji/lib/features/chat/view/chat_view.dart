import 'package:bunji/app/routes.dart';
import 'package:bunji/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: GlassScaffold(
          bottomEdgeFade: true,
          extendBody: true,
          appBar: GlassAppBar(
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
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              spacing: 16,
              children: [
                Expanded(child: GlassTextField(placeholder: 'Ask Bunji...')),
                BunjiButton(icon: const Icon(Icons.attach_file), onTap: () {}),
                BunjiButton(
                  icon: const Icon(Icons.arrow_upward_rounded),
                  buttonColor: cs.primary,
                  onTap: () {},
                ),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 110),
            children: [
              _buildUserMessage(
                context,
                message:
                    'How does on-device AI protect my privacy compared to cloud models?',
                time: '10:24 AM',
              ),
              const SizedBox(height: 16),
              _buildAiMessage(
                context,
                message:
                    'Because Bunji runs locally on your device, your prompts, notes, and personal data never leave your phone. There are no external servers, no tracking, and zero cloud logging — everything is processed directly on your hardware.',
                time: '10:24 AM',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserMessage(
    BuildContext context, {
    required String message,
    required String time,
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
            topLeft: Radius.circular(38),
            topRight: Radius.circular(6),
            bottomLeft: Radius.circular(38),
            bottomRight: Radius.circular(38),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(color: cs.onPrimary, fontSize: 15, height: 1.35),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: cs.onPrimary.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiMessage(
    BuildContext context, {
    required String message,
    required String time,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(color: cs.onSurface, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.45),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
