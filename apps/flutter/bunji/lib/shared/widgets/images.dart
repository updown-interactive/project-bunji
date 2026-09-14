import 'package:flutter/material.dart';

enum AppImages {
  bunji("assets/images/bunji.png");

  final String path;
  const AppImages(this.path);
}

class Images extends StatelessWidget {
  final AppImages image;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final Color? color;
  final BlendMode? colorBlendMode;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final ImageFrameBuilder? frameBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final Animation<double>? opacity;
  final FilterQuality filterQuality;
  final int? cacheWidth;
  final int? cacheHeight;
  const Images(this.image,{
    super.key,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.frameBuilder,
    this.errorBuilder,
    this.opacity,
    this.filterQuality = FilterQuality.medium,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image.path,
      key: key,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      opacity: opacity,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }
}
