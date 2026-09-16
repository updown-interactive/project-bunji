import 'package:bunji/app/di.dart';
import 'package:bunji/app/routes.dart';
import 'package:bunji/features/menu/view/menu_view.dart';
import 'package:bunji/shared/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class FakeDatabaseService implements DatabaseService {
  @override
  Stream<List<ChatSession>> watchRecentChatSessions({int limit = 10}) =>
      Stream.value([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeDatabaseService db;

  setUp(() async {
    await sl.reset();
    db = FakeDatabaseService();
    sl.registerLazySingleton<DatabaseService>(() => db);
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('MenuView renders models tile and navigates on tap',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool navigatedToModels = false;

    final testRouter = GoRouter(
      initialLocation: '/menu',
      routes: [
        GoRoute(
          path: '/menu',
          builder: (context, state) => const MenuView(),
        ),
        GoRoute(
          path: Routes.models.path,
          builder: (context, state) {
            navigatedToModels = true;
            return const Scaffold(body: Text('Models Screen'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: testRouter,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MenuView), findsOneWidget);
    expect(find.text('Models'), findsOneWidget);

    // Tap the models tile
    await tester.tap(find.text('Models'));
    await tester.pumpAndSettle();

    expect(navigatedToModels, isTrue);
    expect(find.text('Models Screen'), findsOneWidget);
  });
}
