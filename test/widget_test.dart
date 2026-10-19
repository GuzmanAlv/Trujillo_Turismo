import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trujillo_cultura/src/app.dart';
import 'package:trujillo_cultura/src/state.dart';
import 'memory_store.dart';

void main() {
  testWidgets('Mobile navigation, detail and agenda work at 390px', (
    tester,
  ) async {
    final originalHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      FlutterError.dumpErrorToConsole(details);
      originalHandler?.call(details);
    };
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AppState(store: MemoryStore());
    await state.initialize();
    await tester.pumpWidget(TramaApp(state: state));
    await tester.pumpAndSettle();
    expect(find.text('Encuentra tu\npróximo encuentro.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Guardar').hitTestable(),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar').hitTestable().first);
    await tester.pumpAndSettle();
    expect(state.saved, isNotEmpty);
    await tester.tap(find.text('Mi agenda'));
    await tester.pumpAndSettle();
    expect(find.text('Tu agenda cultural'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cerca de mí'));
    await tester.pumpAndSettle();
    expect(find.text('Mapa ilustrativo'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Mi perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar a mi espacio'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Ana');
    await tester.tap(find.text('Entrar en modo demo'));
    await tester.pumpAndSettle();
    expect(find.text('Hola, Ana'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
