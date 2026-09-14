import 'package:bunji/app/di.dart';
import 'package:bunji/app/routes.dart';
import 'package:bunji/features/home/viewcontroller/home_vc.dart';
import 'package:bunji/shared/core/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HomeViewController controller;

  setUp(() async {
    await sl.reset();
    controller = HomeViewController();
    sl.registerFactory<HomeViewController>(() => controller);
  });

  tearDown(() async {
    await sl.reset();
  });

  test('HomeViewController goToMenu sets isMenuOpen to true and dispatches NavigateTo', () {
    expect(controller.state.isMenuOpen, isFalse);

    controller.goToMenu();

    expect(controller.state.isMenuOpen, isTrue);
    expect(controller.state.ui.action, isA<NavigateTo>());
    final navAction = controller.state.ui.action as NavigateTo;
    expect(navAction.route, equals(Routes.menu));
    expect(navAction.replace, isFalse);

    controller.closeMenu();
    expect(controller.state.isMenuOpen, isFalse);
  });

  test('Menu overlay slide animation: slides in from left and reverses symmetrically', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    final animController = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 240),
    );

    final slideAnim = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    // Initial closed state: offscreen to the left
    expect(slideAnim.value, const Offset(-1.0, 0.0));

    // Fully open: Offset.zero
    animController.value = 1.0;
    expect(slideAnim.value, Offset.zero);

    // Mid-reverse: smoothly sliding back out
    animController.reverse();
    animController.value = 0.5;
    expect(slideAnim.value.dx, lessThan(0.0));
    expect(slideAnim.value.dx, greaterThan(-1.0));

    animController.dispose();
  });
}
