import 'package:bunji/app/bunji.dart';
import 'package:bunji/app/di.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  inject();
  sl<BunjiModelCatalog>().load().ignore();
  runApp(const Bunji());
}
