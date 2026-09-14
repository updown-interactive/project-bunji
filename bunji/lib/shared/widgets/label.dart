import 'package:flutter/material.dart';

enum AppText {
  bunji("Bunji"),
  images("Images"),
  models("Models"),
  history("History"),
  pinned("Pinned"),
  memory("Memory"),
  recents("Recents"),
  general("General"),
  settings("Settings"),
  notifications("Notifications"),
  enableNotification("Enable notifications"),
  profile("Profile"),
  aiAndModels("AI & Models"),
  privacyAndData("Privacy & Data"),
  chat("Chat"),
  appearance("Appearance"),
  storage("Storage"),
  appBehavior("App Behavior"),
  language("Language"),
  advanced("Advanced"),
  helpAndAbout("Help & About");

  final String path;
  const AppText(this.path);
}

class Label extends StatelessWidget {
  final AppText? text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final String? semanticsIdentifier;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  const Label(
    this.text, {
    super.key,

    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text?.path ?? "",
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      semanticsIdentifier: semanticsIdentifier,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
