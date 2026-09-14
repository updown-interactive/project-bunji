import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:bunji/app/themes.dart';
import 'package:flutter/material.dart';

/// Coordinator to allow tap origin tracking if needed.
abstract class ThemeTransitionCoordinator {
  static Offset? tapOrigin;
}

/// An organic liquid wave theme transition that starts at the top of the screen
/// and cascades down across the interface, realistically washing over the UI
/// and transforming the theme with fluid refraction, specular crests, and depth shadows.
///
/// Strictly monochromatic with zero primary color accents.
class ThemeTransitionOverlay extends StatefulWidget {
  final String themeMode;
  final Widget child;

  const ThemeTransitionOverlay({
    super.key,
    required this.themeMode,
    required this.child,
  });

  @override
  State<ThemeTransitionOverlay> createState() => _ThemeTransitionOverlayState();
}

class _ThemeTransitionOverlayState extends State<ThemeTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isTargetDark = false;
  static const double _waveAmplitude = 24.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 880),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
        }
      });
  }

  @override
  void didUpdateWidget(covariant ThemeTransitionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeMode != widget.themeMode) {
      final currentBrightness = Theme.of(context).brightness;
      final targetIsDark = widget.themeMode.toLowerCase() == 'dark' ||
          (widget.themeMode.toLowerCase() == 'system' &&
              currentBrightness == Brightness.dark);

      setState(() {
        _isTargetDark = targetIsDark;
      });

      // Clear any tap origin
      ThemeTransitionCoordinator.tapOrigin = null;

      // Start the top-down cascading fluid wave
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base content
        widget.child,

        // Liquid wave animation (only mounted during active transition)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (!_controller.isAnimating) {
              return const SizedBox.shrink();
            }

            final progress = _controller.value;

            return IgnorePointer(
              child: CustomPaint(
                painter: _ThemeCascadingWavePainter(
                  progress: progress,
                  amplitude: _waveAmplitude,
                  isTargetDark: _isTargetDark,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Helper function to calculate the undulating wave crest Y coordinate across x.
double _calculateWaveY(
  double x,
  Size size,
  double baseline,
  double progress,
  double amplitude,
) {
  // Harmonic 1: Broad fluid swell
  final w1 = math.sin((x / (size.width * 0.65)) * 2 * math.pi + progress * 3.8) *
      amplitude;
  // Harmonic 2: Finer secondary wave contour
  final w2 =
      math.cos((x / (size.width * 0.38)) * 2 * math.pi - progress * 2.6) *
          (amplitude * 0.35);

  return baseline + w1 + w2;
}

/// Helper function to calculate the secondary trailing ripple Y coordinate.
double _calculateSecondaryWaveY(
  double x,
  Size size,
  double baseline,
  double progress,
  double amplitude,
) {
  final w = math.sin((x / (size.width * 0.45)) * 2 * math.pi + progress * 4.5) *
      (amplitude * 0.4);
  return baseline - 28.0 + w;
}

/// Builds the closed polygon path from top of the screen down to the wave crest.
Path _buildWaveBodyPath(Size size, double progress, double amplitude) {
  // Smooth easing curve: Starts gentle, rolls fluidly, decelerates off screen
  final eased = Curves.easeInOutCubic.transform(progress);
  final travelDistance = size.height + (amplitude * 5);
  final baseline = (eased * travelDistance) - (amplitude * 2.5);

  final path = Path();
  path.moveTo(0, 0);
  path.lineTo(0, _calculateWaveY(0, size, baseline, eased, amplitude));

  for (double x = 2; x <= size.width; x += 3) {
    path.lineTo(x, _calculateWaveY(x, size, baseline, eased, amplitude));
  }

  path.lineTo(
    size.width,
    _calculateWaveY(size.width, size, baseline, eased, amplitude),
  );
  path.lineTo(size.width, 0);
  path.close();

  return path;
}

/// Builds the crest line path (the leading edge contour).
Path _buildWaveCrestPath(Size size, double progress, double amplitude) {
  final eased = Curves.easeInOutCubic.transform(progress);
  final travelDistance = size.height + (amplitude * 5);
  final baseline = (eased * travelDistance) - (amplitude * 2.5);

  final path = Path();
  path.moveTo(0, _calculateWaveY(0, size, baseline, eased, amplitude));

  for (double x = 2; x <= size.width; x += 3) {
    path.lineTo(x, _calculateWaveY(x, size, baseline, eased, amplitude));
  }

  return path;
}

/// Builds the secondary trailing wave crest path.
Path _buildSecondaryCrestPath(Size size, double progress, double amplitude) {
  final eased = Curves.easeInOutCubic.transform(progress);
  final travelDistance = size.height + (amplitude * 5);
  final baseline = (eased * travelDistance) - (amplitude * 2.5);

  final path = Path();
  path.moveTo(0, _calculateSecondaryWaveY(0, size, baseline, eased, amplitude));

  for (double x = 2; x <= size.width; x += 3) {
    path.lineTo(
      x,
      _calculateSecondaryWaveY(x, size, baseline, eased, amplitude),
    );
  }

  return path;
}


/// Custom painter that renders the cascading fluid wave with monochromatic optics.
class _ThemeCascadingWavePainter extends CustomPainter {
  final double progress;
  final double amplitude;
  final bool isTargetDark;

  _ThemeCascadingWavePainter({
    required this.progress,
    required this.amplitude,
    required this.isTargetDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final waveBodyPath = _buildWaveBodyPath(size, progress, amplitude);
    final waveCrestPath = _buildWaveCrestPath(size, progress, amplitude);
    final secondaryCrestPath =
        _buildSecondaryCrestPath(size, progress, amplitude);

    final targetSurfaceColor =
        isTargetDark ? AppColors.darkSurface : AppColors.lightSurface;

    // 1. Ambient depth shadow cast beneath the wave crest onto unreached UI
    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
      ..color = Colors.black.withValues(alpha: isTargetDark ? 0.28 : 0.16);
    canvas.drawPath(waveCrestPath, shadowPaint);

    // 2. Liquid wave body wash (flowing new theme surface from top)
    final bodyPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height * (progress * 1.1).clamp(0.2, 1.0)),
        [
          targetSurfaceColor.withValues(alpha: 0.98),
          targetSurfaceColor.withValues(alpha: 0.92),
        ],
      );
    canvas.drawPath(waveBodyPath, bodyPaint);

    // 3. Secondary trailing harmonic ripple line
    final secondaryCrestPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = (isTargetDark ? Colors.white : Colors.white)
          .withValues(alpha: isTargetDark ? 0.16 : 0.4);
    canvas.drawPath(secondaryCrestPath, secondaryCrestPaint);

    // 4. Soft specular crest bloom
    final crestBloomPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..color = (isTargetDark ? Colors.white : Colors.black)
          .withValues(alpha: isTargetDark ? 0.14 : 0.08);
    canvas.drawPath(waveCrestPath, crestBloomPaint);

    // 5. Crisp glistening liquid meniscus crest line (strictly monochromatic)
    final crestLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = (isTargetDark ? Colors.white : Colors.white)
          .withValues(alpha: isTargetDark ? 0.38 : 0.72);
    canvas.drawPath(waveCrestPath, crestLinePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ThemeCascadingWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
