import 'package:bunji/shared/widgets/theme_transition_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeTransitionOverlay Tests', () {
    testWidgets('unmounts overlay completely once animation completes',
        (tester) async {
      var currentTheme = 'light';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: ThemeTransitionOverlay(
                  themeMode: currentTheme,
                  child: const Text('Bunji Screen Content'),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      currentTheme = 'dark';
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      final waveFinder = find.byWidgetPredicate(
        (w) =>
            w is CustomPaint &&
            w.painter?.runtimeType.toString() == '_ThemeCascadingWavePainter',
      );

      // Initially no CustomPaint for wave overlay
      expect(find.text('Bunji Screen Content'), findsOneWidget);
      expect(waveFinder, findsNothing);

      // Trigger theme change
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Wave is actively animating
      expect(waveFinder, findsOneWidget);

      // Pump past the 880ms duration so the animation finishes
      await tester.pump(const Duration(milliseconds: 1000));

      // Once animation completes, overlay is strictly unmounted (SizedBox.shrink)
      expect(waveFinder, findsNothing);
      expect(find.text('Bunji Screen Content'), findsOneWidget);
    });
  });
}
