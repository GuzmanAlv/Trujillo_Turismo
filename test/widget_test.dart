import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trujillo_cultura/src/app.dart';
import 'package:trujillo_cultura/src/state.dart';
import 'memory_store.dart';

void main() {
  Future<void> registerDemo(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Regístrate aquí'));
    await tester.tap(find.text('Regístrate aquí'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('auth-name')), 'Ana');
    await tester.enterText(
      find.byKey(const Key('auth-email')),
      'ana@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('auth-password')),
      'clave-demo',
    );
    await tester.enterText(
      find.byKey(const Key('auth-confirmation')),
      'clave-demo',
    );
    await tester.ensureVisible(find.text('Registrarme'));
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();
  }

  Future<AppState> launch(WidgetTester tester, {bool signedIn = false}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AppState(store: MemoryStore());
    await state.initialize();
    if (signedIn) await state.demoLogin('Ana');
    await tester.pumpWidget(TramaApp(state: state));
    await tester.pumpAndSettle();
    return state;
  }

  testWidgets('Guest save requires access and resumes after login', (
    tester,
  ) async {
    final state = await launch(tester);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.textContaining('Google'), findsNothing);
    expect(find.textContaining('Olvidaste'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Explorar como invitado →'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Explorar como invitado →'), findsOneWidget);
    await tester.tap(find.text('Explorar como invitado →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mi agenda'));
    await tester.pumpAndSettle();
    expect(find.text('Tus planes, en tu espacio'), findsOneWidget);
    expect(find.text('Tu agenda cultural'), findsNothing);
    await tester.tap(find.text('Descubrir'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Guardar').hitTestable(),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Guardar').hitTestable().first);
    await tester.pumpAndSettle();
    expect(state.saved, isEmpty);
    await tester.tap(find.text('Seguir explorando'));
    await tester.pumpAndSettle();
    expect(state.saved, isEmpty);
    await tester.tap(find.text('Guardar').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar a mi espacio').hitTestable().first);
    await tester.pumpAndSettle();
    await registerDemo(tester);
    await tester.pumpAndSettle();
    expect(find.text('¿Qué te gustaría descubrir?'), findsOneWidget);
    await tester.tap(find.text('Empezar a descubrir'));
    await tester.pumpAndSettle();
    expect(state.saved, hasLength(1));
    await tester.tap(find.text('Mi agenda'));
    await tester.pumpAndSettle();
    expect(find.text('Tu agenda cultural'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Welcome login offers interests and sign out restores welcome', (
    tester,
  ) async {
    await launch(tester);

    await registerDemo(tester);
    await tester.pumpAndSettle();
    expect(find.text('¿Qué te gustaría descubrir?'), findsOneWidget);
    await tester.tap(find.text('Empezar a descubrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mi perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Hola, Ana'), findsOneWidget);
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Explorar como invitado →'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Explorar como invitado →'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byKey(const Key('auth-email')), 'ana@example.test');
    await tester.enterText(find.byKey(const Key('auth-password')), 'incorrecta');
    await tester.ensureVisible(find.text('Ingresar'));
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Correo o contraseña incorrectos'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('auth-password')), 'clave-demo');
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();
    expect(find.text('Encuentra tu\npróximo encuentro.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Returning user skips welcome and map works', (tester) async {
    await launch(tester, signedIn: true);
    expect(find.text('Encuentra tu\npróximo encuentro.'), findsOneWidget);
    expect(find.text('Explorar como invitado →'), findsNothing);
    await tester.tap(find.text('Cerca de mí'));
    await tester.pumpAndSettle();
    expect(find.text('Mapa ilustrativo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
