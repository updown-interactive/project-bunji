import 'package:bunji/features/chat/view/chat_view.dart';
import 'package:bunji/features/home/view/home_view.dart';
import 'package:bunji/features/menu/view/menu_view.dart';
import 'package:bunji/features/models/view/models_view.dart';
import 'package:bunji/features/onboarding/view/onboarding_view.dart';
import 'package:bunji/features/onboarding/view/splash_view.dart';
import 'package:bunji/features/profile/view/profile_view.dart';
import 'package:bunji/features/settings/view/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum Routes {
  splash("/", "splash"),
  onboarding("/onboarding", "onboarding"),
  chat("/chat", "chat"),
  menu("/menu", "menu"),
  home("/home", "home"),
  profile("/profile", "profile"),
  settings("/settings", "settings"),
  models("/models", "models");

  final String path, name;
  const Routes(this.path, this.name);
}

final _splashRoute = GoRoute(
  path: Routes.splash.path,
  name: Routes.splash.name,
  builder: (context, state) {
    return const SplashView();
  },
);

final _onboardingRoute = GoRoute(
  path: Routes.onboarding.path,
  name: Routes.onboarding.name,
  builder: (context, state) {
    return const OnboardingView();
  },
);

final _chatRoute = GoRoute(
  path: Routes.chat.path,
  name: Routes.chat.name,
  pageBuilder: (context, state) {
    final chatId = state.extra as String?;
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: ChatView(chatId: chatId),
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.08),
          end: Offset.zero,
        ).animate(curvedAnimation);

        final scaleAnimation = Tween<double>(
          begin: 0.94,
          end: 1.0,
        ).animate(curvedAnimation);

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(curvedAnimation);

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(scale: scaleAnimation, child: child),
          ),
        );
      },
    );
  },
);

final _homeRoute = GoRoute(
  path: Routes.home.path,
  name: Routes.home.name,
  builder: (context, state) {
    return const HomeView();
  },
);

final _menuRoute = GoRoute(
  path: Routes.menu.path,
  name: Routes.menu.name,
  pageBuilder: (context, state) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      child: const MenuView(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  },
);

final _profileRoute = GoRoute(
  path: Routes.profile.path,
  name: Routes.profile.name,
  builder: (context, state) {
    return const ProfileView();
  },
);

final _settingsRoute = GoRoute(
  path: Routes.settings.path,
  name: Routes.settings.name,
  builder: (context, state) {
    return const SettingsView();
  },
);

final _modelsRoute = GoRoute(
  path: Routes.models.path,
  name: Routes.models.name,
  builder: (context, state) {
    return const ModelsView();
  },
);

final router = GoRouter(
  initialLocation: Routes.splash.path,
  routes: [
    _splashRoute,
    _onboardingRoute,
    _homeRoute,
    _chatRoute,
    _menuRoute,
    _profileRoute,
    _settingsRoute,
    _modelsRoute,
  ],
);
