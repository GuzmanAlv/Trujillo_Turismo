import 'dart:math';

const categories = [
  'Danza',
  'Música',
  'Arte',
  'Gastronomía',
  'Teatro',
  'Patrimonio',
];
const months = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];
String shortDate(DateTime d) => '${d.day} ${months[d.month - 1]}';
String hour(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class CulturalEvent {
  final String id,
      title,
      category,
      venue,
      organizer,
      description,
      source,
      sourceUrl;
  final DateTime start;
  final double latitude, longitude, price;
  final int art;
  const CulturalEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.venue,
    required this.organizer,
    required this.description,
    required this.start,
    required this.latitude,
    required this.longitude,
    required this.price,
    this.art = 0,
    this.source = 'Agenda de muestra',
    this.sourceUrl = '',
  });
  String get priceLabel =>
      price == 0 ? 'Ingreso libre' : 'S/ ${price.toStringAsFixed(0)}';
  double distanceFrom(double lat, double lng) {
    const r = pi / 180;
    final a =
        pow(sin((latitude - lat) * r / 2), 2) +
        cos(lat * r) *
            cos(latitude * r) *
            pow(sin((longitude - lng) * r / 2), 2);
    return 6371 * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  factory CulturalEvent.fromJson(String id, Map<String, dynamic> j) =>
      CulturalEvent(
        id: id,
        title: j['title'] as String,
        category: j['category'] as String,
        venue: j['venue'] as String,
        organizer: j['organizer'] as String,
        description: j['description'] as String,
        start: DateTime.parse(j['start'] as String).toLocal(),
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
        price: (j['price'] as num).toDouble(),
        art: (j['art'] as num?)?.toInt() ?? 0,
        source: j['source'] as String? ?? 'Organizador',
        sourceUrl: j['sourceUrl'] as String? ?? '',
      );
}

List<CulturalEvent> demoEvents(DateTime anchor) {
  final day = DateTime(anchor.year, anchor.month, anchor.day);
  final rows = [
    [
      'marinera',
      'La marinera\nnos encuentra',
      'Danza',
      'Plaza de Armas · Centro histórico',
      'Colectivo Raíces',
      1,
      18,
      0,
      -8.1116,
      -79.0287,
      0,
    ],
    [
      'jazz',
      'Atardecer con\nsabor a jazz',
      'Música',
      'Paseo de las Aguas · Víctor Larco',
      'Sesiones del Norte',
      2,
      19,
      25,
      -8.1324,
      -79.0454,
      1,
    ],
    [
      'barro',
      'Historias hechas\nde barro',
      'Arte',
      'Casa de la Emancipación · Centro',
      'Taller Tierra Viva',
      3,
      16,
      0,
      -8.1099,
      -79.0264,
      2,
    ],
    [
      'sabores',
      'Sabores de\nnuestra tierra',
      'Gastronomía',
      'Huanchaco · Malecón',
      'Mesa Norteña',
      4,
      12,
      15,
      -8.0805,
      -79.1204,
      3,
    ],
    [
      'teatro',
      'Una noche\nentre historias',
      'Teatro',
      'Teatro Municipal · Centro',
      'Escena Trujillo',
      5,
      19,
      20,
      -8.1109,
      -79.0302,
      4,
    ],
    [
      'chan',
      'Huellas del\nreino Chimú',
      'Patrimonio',
      'Chan Chan · Huanchaco',
      'Memoria del Norte',
      6,
      10,
      0,
      -8.1037,
      -79.0747,
      5,
    ],
    [
      'musica',
      'El norte\nsuena bonito',
      'Música',
      'Plazuela El Recreo · Centro',
      'Encuentro Cultural',
      8,
      17,
      0,
      -8.1054,
      -79.0241,
      1,
    ],
    [
      'danza',
      'Pasos que\ncuentan historias',
      'Danza',
      'Casa de la Identidad · Centro',
      'Colectivo Raíces',
      10,
      16,
      10,
      -8.1123,
      -79.0293,
      0,
    ],
  ];
  return rows
      .map(
        (r) => CulturalEvent(
          id: r[0] as String,
          title: r[1] as String,
          category: r[2] as String,
          venue: r[3] as String,
          organizer: r[4] as String,
          start: day.add(Duration(days: r[5] as int, hours: r[6] as int)),
          price: (r[7] as num).toDouble(),
          latitude: r[8] as double,
          longitude: r[9] as double,
          art: r[10] as int,
          description:
              'Un encuentro para disfrutar y compartir la cultura de nuestra ciudad. Descubre nuevas expresiones, conecta con la comunidad y vive Trujillo a tu manera.\n\nEvento ficticio creado para explorar la aplicación. La fecha, el organizador, el precio y el programa son ilustrativos; no constituyen una convocatoria real.',
        ),
      )
      .toList();
}

List<CulturalEvent> filterEvents(
  List<CulturalEvent> events, {
  String query = '',
  String? category,
  bool freeOnly = false,
  DateTime? day,
  Set<String> interests = const {},
  Set<String> liked = const {},
  double? lat,
  double? lng,
  double? radius,
}) {
  String normalize(String s) {
    var out = s.toLowerCase();
    for (final pair in [
      ['á', 'a'],
      ['é', 'e'],
      ['í', 'i'],
      ['ó', 'o'],
      ['ú', 'u'],
      ['ñ', 'n'],
    ]) {
      out = out.replaceAll(pair[0], pair[1]);
    }
    return out;
  }

  final likedCategories = events
      .where((e) => liked.contains(e.id))
      .map((e) => e.category)
      .toSet();
  final result = events
      .where(
        (e) =>
            (category == null || e.category == category) &&
            (!freeOnly || e.price == 0) &&
            (day == null || sameDay(e.start, day)) &&
            normalize(
              '${e.title} ${e.venue} ${e.category}',
            ).contains(normalize(query.trim())) &&
            (radius == null ||
                lat == null ||
                lng == null ||
                e.distanceFrom(lat, lng) <= radius),
      )
      .toList();
  int score(CulturalEvent e) =>
      (interests.contains(e.category) ? 2 : 0) +
      (likedCategories.contains(e.category) ? 1 : 0);
  result.sort((a, b) {
    final rank = score(b).compareTo(score(a));
    return rank != 0 ? rank : a.start.compareTo(b.start);
  });
  return result;
}
