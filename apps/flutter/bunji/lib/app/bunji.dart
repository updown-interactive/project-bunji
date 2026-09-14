import 'package:bunji/app/di.dart';
import 'package:bunji/app/routes.dart';
import 'package:bunji/app/themes.dart';
import 'package:bunji/features/settings/settings.dart';
import 'package:bunji/shared/widgets/theme_transition_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Bunji extends StatelessWidget {
  const Bunji({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SettingsViewController>()..init(),
      child: BlocBuilder<SettingsViewController, SettingsState>(
        buildWhen: (prev, curr) => prev.themeMode != curr.themeMode,
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: state.flutterThemeMode,
            builder: (context, child) {
              return AnimatedTheme(
                data: Theme.of(context),
                duration: const Duration(milliseconds: 850),
                curve: Curves.easeInOutCubic,
                child: ThemeTransitionOverlay(
                  themeMode: state.themeMode,
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}