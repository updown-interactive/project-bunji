
import 'package:bunji/features/chat/chat.dart';
import 'package:bunji/features/home/home.dart';
import 'package:bunji/features/models/models.dart';
import 'package:bunji/features/onboarding/onboarding.dart';
import 'package:bunji/features/settings/settings.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void inject() {
  registerServices(sl);
  registerOnboarding(sl);
  registerHome(sl);
  registerSettings(sl);
  registerChat(sl);
  registerModels(sl);
}