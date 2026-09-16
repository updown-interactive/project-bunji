import 'package:bunji/features/chat/viewcontroller/chat_vc.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:get_it/get_it.dart';

export 'model/chat_message.dart';
export 'util/chat_title_helper.dart';
export 'viewcontroller/chat_state.dart';
export 'viewcontroller/chat_vc.dart';
export 'view/chat_view.dart';

void registerChat(GetIt sl) {
  sl.registerFactory(
    () => ChatViewController(
      inferenceEngine: sl<BunjiInferenceEngine>(),
      modelManager: sl<BunjiModelManager>(),
      databaseService: sl<DatabaseService>(),
    ),
  );
}
