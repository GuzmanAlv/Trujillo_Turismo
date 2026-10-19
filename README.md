# Trama · Cultura que conecta

Aplicación móvil Flutter para centralizar la difusión cultural de Trujillo, Perú. Identidad visual terracota, crema y verde; ilustraciones vectoriales originales inspiradas en danza, cerámica, música y arquitectura de la costa norte. El nombre Trama es provisional.

## Ejecutar la demo

Requiere Flutter 3.44 o compatible con Dart 3.12 y Android SDK (Android 7/API 24 o posterior).

```sh
flutter pub get
flutter run
```

Vista previa en navegador: `flutter run -d chrome`. Compilar Android: `flutter build apk --debug`. El APK se genera en `build/app/outputs/flutter-apk/app-debug.apk`. La configuración de release todavía usa firma de desarrollo; configurar firma propia antes de publicar.

La demo funciona sin Firebase ni clave Maps. Todos los eventos, organizadores, fechas y precios son ficticios y se identifican como tales. Los lugares y coordenadas son referencias aproximadas. No hay importación de publicaciones reales de Facebook o Instagram.

## Funcionalidades

- Feed vertical con categorías, búsqueda sin distinción de tildes, fecha, eventos próximos y entrada libre; detalle, origen y copiar información para compartir.
- Recomendaciones locales y explicables: 2 puntos por categoría de interés y 1 por categoría de un evento marcado como me gusta. Desempate cronológico.
- Favoritos y calendario mensual con indicadores; navegación por meses y filtro por día.
- Intereses, agenda, reacciones, nombre de demostración y borradores persistidos localmente. El almacenamiento pertenece al dispositivo, no a una cuenta; no se sincroniza entre dispositivos.
- Recordatorios Android aproximadamente una hora antes. Se solicita permiso al activarlos; se usa programación inexacta compatible con ahorro de batería, sin exigir alarmas exactas. Quitar un evento de la agenda cancela su recordatorio. Reinicio contemplado en el manifiesto. Deben verificarse en un dispositivo real.
- Ubicación bajo demanda, distancia geodésica y filtro de 5 km. Avisos de cercanía en Android al consultar ubicación con la opción activada; no geofencing ni rastreo en segundo plano.
- Mapa ilustrativo interactivo en demo. SDK Google Maps Android integrado y activable; enlaces externos de cómo llegar disponibles sin clave propia.
- Acceso demo por nombre. Código de registro y login Firebase con correo/contraseña preparado para activación.
- Propuestas de organizadores guardadas como borradores locales. No se publican ni se cobran promociones.

## Estructura

- `lib/src/event.dart`: modelo, datos ilustrativos, filtros y ranking.
- `lib/src/state.dart`: estado, persistencia, login y catálogo Firebase opcional.
- `lib/src/storage.dart`: interfaz de almacenamiento y adaptador SharedPreferences.
- `lib/src/services.dart`: recordatorios Android y avisos locales.
- `lib/src/app.dart`: navegación, feed, detalle y calendario.
- `lib/src/map_view.dart`: mapa ilustrativo/Google Maps y cercanía.
- `lib/src/profile.dart`: intereses, acceso y borradores de organizadores.
- `lib/src/design.dart`: tema e ilustraciones originales sin dependencias de imágenes remotas.
- `test/`: filtros, ranking, geodistancia, persistencia y recorridos de interfaz móvil.

## Conectar Firebase después

1. Crear o seleccionar un proyecto; registrar Android con application ID `pe.trujillo.cultura.trujillo_cultura`.
2. Activar Authentication > Email/Password y crear Firestore.
3. Copiar `config/demo.example.json` a `config/local.json` (ignorado por Git). Completar API key, app ID, sender ID y project ID del proyecto Firebase y establecer `FIREBASE_ENABLED` en `true`.
4. Ejecutar `flutter run --dart-define-from-file=config/local.json`.
5. Revisar y desplegar `firestore.rules` con Firebase CLI en el proyecto correcto. No se despliega automáticamente. Las reglas permiten leer únicamente eventos publicados; las escrituras quedan reservadas a un servicio administrador.

La inicialización usa `FirebaseOptions` explícitas. No requiere `google-services.json` para estos servicios mientras se suministren todas las opciones. No añadir credenciales de administrador ni cuentas de servicio al cliente.

Colección `events`, un documento por evento:

```json
{
  "title": "Nombre del evento",
  "category": "Danza",
  "venue": "Lugar y dirección",
  "organizer": "Institución organizadora",
  "description": "Programa, público y condiciones",
  "start": "2026-11-01T18:00:00-05:00",
  "latitude": -8.1116,
  "longitude": -79.0287,
  "price": 0,
  "art": 0,
  "source": "Publicación del organizador",
  "sourceUrl": "https://example.org/evento",
  "published": true
}
```

`start` es una cadena ISO 8601 con zona horaria; `price` es numérico. Categorías admitidas: Danza, Música, Arte, Gastronomía, Teatro y Patrimonio. `art` selecciona ilustración 0–5. La carga actual es una consulta del catálogo publicado; añadir paginación, caché remota y validación de esquema antes de un catálogo grande.

## Google Maps Android

1. Habilitar Maps SDK for Android en Google Cloud y crear una clave restringida al application ID y SHA-1 del certificado de la app.
2. Definir `MAPS_API_KEY=...` en el archivo de propiedades de Gradle del usuario (`~/.gradle/gradle.properties`), fuera del repositorio. El build inyecta el valor en el manifiesto.
3. Poner `MAPS_ENABLED` en `true` en `config/local.json` y reconstruir la app.

El SDK integrado está habilitado solo en Android. La vista web sigue usando el mapa ilustrativo. No se ha activado facturación ni consumido crédito de Google Cloud desde este proyecto.

## Siguientes etapas

1. Centralización real: panel editorial, formulario autenticado de organizadores, estados de revisión, trazabilidad de fuentes y fechas de actualización; deduplicación por URL/organizador/fecha. Las APIs de Meta requieren su propia autorización y alcance; no hay scraper implementado ni extracción automática prometida.
2. Sincronizar favoritos, intereses y agenda por UID; aislar preferencias por cuenta, añadir recuperación de contraseña, eliminación de cuenta y política de privacidad.
3. Validar recordatorios en dispositivos reales, cancelaciones y cambios de fecha; Firebase Cloud Messaging para avisos de nuevos eventos. Geofencing sería un módulo separado con permisos y consentimiento específicos.
4. Organizaciones verificadas, moderación, promoción marcada como patrocinada, límites presupuestarios y pagos. El ranking orgánico actual no incluye publicidad.
5. Tests de reglas de Firestore con emuladores, paginación y controles de costos antes de producción. iOS requiere generar la plataforma y configurar firma/permisos en macOS; este entregable genera Android y una vista previa web.

## Verificación

```sh
flutter analyze
flutter test
flutter build web --release
flutter build apk --debug
```

No confundir una compilación correcta con una prueba real de credenciales, permisos o notificaciones del dispositivo.

## Documentación de integración

- [Firebase para Flutter](https://firebase.google.com/docs/flutter/setup)
- [Google Maps para Flutter](https://pub.dev/packages/google_maps_flutter)
- [Persistencia local](https://pub.dev/packages/shared_preferences)
- [Notificaciones locales, versión utilizada](https://pub.dev/packages/flutter_local_notifications/versions/19.5.0)
