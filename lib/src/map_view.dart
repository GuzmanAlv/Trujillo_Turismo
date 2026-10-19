import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'app.dart';
import 'design.dart';
import 'event.dart';
import 'state.dart';

class MapView extends StatefulWidget {
  final AppState state;
  const MapView({super.key, required this.state});
  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  String? selectedId;
  bool locating = false, nearOnly = false;
  String? category;
  GoogleMapController? controller;
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> locate() async {
    setState(() => locating = true);
    try {
      await widget.state.locate();
      await controller?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.state.latitude!, widget.state.longitude!),
        ),
      );
      if (mounted) setState(() => nearOnly = true);
    } catch (e) {
      if (mounted) {
        toast(
          context,
          e is StateError
              ? e.message.toString()
              : 'No pudimos obtener tu ubicación. Inténtalo de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final events = filterEvents(
      s.events,
      category: category,
      lat: s.latitude,
      lng: s.longitude,
      radius: nearOnly ? 5 : null,
    );
    if (s.latitude != null) {
      events.sort(
        (a, b) => a
            .distanceFrom(s.latitude!, s.longitude!)
            .compareTo(b.distanceFrom(s.latitude!, s.longitude!)),
      );
    }
    final selected =
        events.where((e) => e.id == selectedId).firstOrNull ??
        events.firstOrNull;
    final nativeMap =
        AppState.mapsEnabled &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Eyebrow('La ciudad es tu escenario'),
        const SizedBox(height: 10),
        Text(
          'Cultura cerca de ti',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        const Text(
          'Encuentra un nuevo plan a la vuelta de la esquina.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Todos'),
                selected: category == null,
                onSelected: (_) => setState(() => category = null),
              ),
              const SizedBox(width: 8),
              for (final c in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(c),
                    selected: category == c,
                    onSelected: (_) =>
                        setState(() => category = category == c ? null : c),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 350,
            child: nativeMap
                ? GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(-8.1116, -79.0287),
                      zoom: 13,
                    ),
                    onMapCreated: (c) => controller = c,
                    myLocationEnabled: s.latitude != null,
                    myLocationButtonEnabled: false,
                    markers: events
                        .map(
                          (e) => Marker(
                            markerId: MarkerId(e.id),
                            position: LatLng(e.latitude, e.longitude),
                            infoWindow: InfoWindow(
                              title: e.title.replaceAll('\n', ' '),
                              snippet: e.venue,
                            ),
                            onTap: () => setState(() => selectedId = e.id),
                          ),
                        )
                        .toSet(),
                  )
                : LayoutBuilder(
                    builder: (context, size) => Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _CityPainter()),
                        ),
                        const Positioned(
                          left: 16,
                          top: 16,
                          child: Chip(
                            label: Text(
                              'Mapa ilustrativo',
                              style: TextStyle(fontSize: 11),
                            ),
                            avatar: Icon(Icons.info_outline, size: 16),
                          ),
                        ),
                        const Positioned(
                          left: 12,
                          top: 166,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              'OCÉANO PACÍFICO',
                              style: TextStyle(
                                color: Color(0xFF6B8F8F),
                                fontSize: 9,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: size.maxWidth * .49,
                          top: 196,
                          child: const Text(
                            'TRUJILLO',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        for (final e in events)
                          Positioned(
                            left:
                                ((e.longitude + 79.14) /
                                        .14 *
                                        (size.maxWidth - 60))
                                    .clamp(8, size.maxWidth - 48),
                            top: ((-8.06 - e.latitude) / .10 * 250 + 30).clamp(
                              30,
                              295,
                            ),
                            child: IconButton.filled(
                              tooltip: e.title.replaceAll('\n', ' '),
                              style: IconButton.styleFrom(
                                backgroundColor: selected?.id == e.id
                                    ? terra
                                    : ink,
                                minimumSize: const Size(40, 40),
                              ),
                              onPressed: () =>
                                  setState(() => selectedId = e.id),
                              icon: Icon(
                                categoryIcons[categories
                                    .indexOf(e.category)
                                    .clamp(0, 5)],
                                size: 19,
                              ),
                            ),
                          ),
                        const Positioned(
                          bottom: 12,
                          right: 12,
                          child: Text(
                            'Referencia visual · no usar para navegar',
                            style: TextStyle(fontSize: 9, color: muted),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.tonalIcon(
              onPressed: locating ? null : locate,
              icon: locating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(locating ? 'Buscando…' : 'Usar mi ubicación'),
            ),
            FilterChip(
              label: const Text('A menos de 5 km'),
              selected: nearOnly,
              onSelected: (v) {
                if (v && s.latitude == null) {
                  locate();
                } else {
                  setState(() => nearOnly = v);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!nativeMap)
          const Text(
            'Puedes explorar los puntos de ejemplo o abrir la ubicación real del lugar en Google Maps.',
            style: TextStyle(fontSize: 12, color: muted),
          ),
        const SizedBox(height: 22),
        Text(
          '${events.length} encuentros por descubrir',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        if (events.isEmpty)
          const EmptyState(
            title: 'Exploremos un poco más lejos',
            body:
                'No hay eventos dentro de este radio. Desactiva el filtro de 5 km para ver todos.',
          ),
        if (selected != null) EventCard(event: selected, state: s),
        for (final e in events.where((e) => e.id != selected?.id))
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFEDE8DC),
              child: Icon(
                categoryIcons[categories.indexOf(e.category).clamp(0, 5)],
                color: terra,
              ),
            ),
            title: Text(
              e.title.replaceAll('\n', ' '),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              '${shortDate(e.start)} · ${s.latitude == null ? e.venue : '${e.distanceFrom(s.latitude!, s.longitude!).toStringAsFixed(1)} km'}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showEvent(context, e, s),
          ),
      ],
    );
  }
}

class _CityPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = const Color(0xFFECEBDD);
    c.drawRect(Offset.zero & s, p);
    p.color = const Color(0xFFC9DEDA);
    c.drawPath(
      Path()
        ..lineTo(s.width * .18, 0)
        ..lineTo(s.width * .38, s.height)
        ..lineTo(0, s.height)
        ..close(),
      p,
    );
    c.save();
    c.translate(s.width * .55, s.height * .5);
    c.rotate(-.3);
    p
      ..color = const Color(0xFFFCFAF3)
      ..strokeWidth = 9;
    for (double x = -120; x < s.width; x += 42) {
      c.drawLine(Offset(x, -400), Offset(x, 400), p);
    }
    for (double y = -300; y < 400; y += 42) {
      c.drawLine(Offset(-120, y), Offset(s.width, y), p);
    }
    p.color = const Color(0xFFB4C7A2);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 32, 32),
        const Radius.circular(6),
      ),
      p,
    );
    c.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
