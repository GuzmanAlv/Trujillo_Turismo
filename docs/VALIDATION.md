# Validación de la demo · 19 de octubre de 2026

- `flutter analyze --no-pub`: sin incidencias.
- `flutter test --no-pub`: 5 pruebas correctas.
- `flutter build web --release --no-wasm-dry-run`: compilación correcta.
- Revisión visual del feed y mapa a 390 × 844 píxeles; capturas en esta carpeta.

Las pruebas cubren búsqueda por texto y tildes, combinación de filtros, recomendaciones, radio geográfico, conservación de preferencias al recrear el estado y navegación móvil (guardar, agenda, mapa y acceso demo).

La app usa eventos ficticios. No se han validado credenciales Firebase/Maps ni notificaciones en un teléfono real. La vista web utiliza un mapa ilustrativo, y los recordatorios del sistema son exclusivos de Android.

Para abrir la vista web compilada: `node tool/preview.cjs`, después visitar http://127.0.0.1:5180. El servidor está limitado a la interfaz local del equipo.

- Android: flutter build apk --debug completado correctamente. APK: build/app/outputs/flutter-apk/app-debug.apk. No instalado ni probado en un teléfono físico.
