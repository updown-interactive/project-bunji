import 'package:bunji/app/di.dart';
import 'package:bunji/features/onboarding/viewcontrollers/splash_vc.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:bunji/shared/widgets/images.dart';
import 'package:bunji/shared/widgets/label.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashViewController>()..init(),
      child: const _SplashContent(),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return BlocConsumer<SplashViewController, SplashState>(
      listenWhen: (previous, current) => current.ui.action != null,
      listener: (context, state) {
        final action = state.ui.action;
        final controller = context.read<SplashViewController>();

        if (action is NavigateTo) {
          if (action.replace) {
            context.go(action.route.path, extra: action.args);
          } else {
            context.push(action.route.path, extra: action.args);
          }
          controller.clearAction();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: cs.primary,
          body: Center(
            child: Row(
              mainAxisAlignment: .center,
              children: [
                Label(
                  .bunji,
                  style: tt.displayLarge?.copyWith(color: cs.onPrimary),
                ),
                Images(.bunji, height: 80, width: 80, color: cs.onPrimary),
              ],
            ),
          ),
        );
      },
    );
  }
}
