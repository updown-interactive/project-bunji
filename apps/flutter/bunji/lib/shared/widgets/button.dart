import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class BunjiButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final String? title;
  final Color? buttonColor;
  final double? height, width;
  const BunjiButton({
    super.key,
    required this.icon,
    required this.onTap,
     this.title,
    this.buttonColor,
    this.height = 46,
    this.width = 46,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GlassButton(
      height: height,
      width: width,
      settings: LiquidGlassSettings(
        glassColor: buttonColor ?? cs.surfaceContainer.withValues(alpha: 0.5),
      ),
      icon: icon,
      onTap: onTap,
      label: title ?? "",
    );
  }
}
