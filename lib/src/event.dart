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
  final String? imageAsset;
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
    this.imageAsset,
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
        imageAsset: j['imageAsset'] as String?,
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
    [
      "acuarela",
      "Trujillo en\nacuarelas",
      "Arte",
      "Casa de la Emancipación · Centro",
      "Atelier de la Ciudad",
      4,
      10,
      35,
      -8.1099,
      -79.0264,
      2,
    ],
    [
      "ceviche",
      "Ceviche con\nsabor a mar",
      "Gastronomía",
      "Huanchaco · Taller de cocina",
      "Cocina del Pacífico",
      6,
      13,
      45,
      -8.0805,
      -79.1204,
      3,
    ],
    [
      "titeres",
      "Pequeñas historias,\ngrandes aventuras",
      "Teatro",
      "Casa de la Identidad · Centro",
      "La Maleta de los Títeres",
      7,
      11,
      0,
      -8.1123,
      -79.0293,
      4,
    ],
    [
      "balcones",
      "Entre balcones\ny casonas",
      "Patrimonio",
      "Plaza de Armas · Punto de encuentro",
      "Caminantes del Centro",
      9,
      9,
      0,
      -8.1116,
      -79.0287,
      5,
    ],
    [
      "fotografia",
      "Miradas de\nla costa norte",
      "Arte",
      "Casa de la Identidad · Centro",
      "Colectivo Enfoque Norte",
      11,
      17,
      0,
      -8.1123,
      -79.0293,
      2,
    ],
    [
      "cajon",
      "El pulso\ndel cajón",
      "Música",
      "Centro cultural · Víctor Larco",
      "Ritmo y Madera",
      12,
      16,
      20,
      -8.1324,
      -79.0454,
      1,
    ],
    [
      "pan",
      "Pan, tradición\ny manos a la masa",
      "Gastronomía",
      "Taller gastronómico · Centro",
      "Horno de Barrio",
      14,
      10,
      30,
      -8.1088,
      -79.0274,
      3,
    ],
    [
      "huacas",
      "Colores de\nla cultura Moche",
      "Patrimonio",
      "Huaca de la Luna · Moche",
      "Rutas de la Memoria",
      16,
      9,
      25,
      -8.1355,
      -78.9908,
      5,
    ],
    [
      "impro",
      "Una noche\nsin guion",
      "Teatro",
      "Sala cultural · Centro histórico",
      "Impro Norte",
      19,
      20,
      18,
      -8.1109,
      -79.0302,
      4,
    ],
    [
      "festejo",
      "Ritmo que\nse celebra",
      "Danza",
      "Patio cultural · Centro",
      "Movimiento y Raíz",
      22,
      18,
      0,
      -8.1054,
      -79.0241,
      0,
    ],
  ];
  final descriptions = <String, String>{
    "marinera": "Exhibición de marinera norteña con parejas invitadas y una breve introducción a sus pasos, vestuario y pañuelos. Una propuesta abierta para disfrutar en familia.",
    "jazz": "Una sesión íntima de saxofón, contrabajo y batería al atardecer. El programa de muestra combina estándares de jazz con ritmos de la costa peruana.",
    "barro": "Acércate al proceso de modelado de una pieza de cerámica: preparación del barro, formas y acabados inspirados en la tradición del norte. Incluye una demostración artesanal.",
    "sabores": "Recorre una feria de cocina norteña con propuestas de arroz con pato, shámbar y sabores del litoral. El precio de muestra corresponde al acceso; las degustaciones se presentan por separado.",
    "teatro": "Una puesta en escena sobre los recuerdos y encuentros de un barrio trujillano. El recorrido teatral combina música, personajes y una conversación final con el elenco.",
    "chan": "Recorrido interpretativo por la arquitectura de adobe y los relieves del mundo Chimú. Lleva agua, sombrero y calzado cómodo para una visita diurna.",
    "musica": "Un encuentro al aire libre con guitarra, cajón y repertorio de la costa norte. Una tarde para escuchar nuevas voces y compartir música en la plazuela.",
    "danza": "Taller introductorio de marinera para practicar postura, coordinación y pasos básicos. No necesitas experiencia previa; se recomienda ropa cómoda y un pañuelo.",
    "acuarela": "Pinta una escena del centro histórico mientras aprendes a mezclar colores y trabajar transparencias. La propuesta incluye papel, pinceles y materiales de práctica.",
    "ceviche": "Demostración participativa de preparación y presentación de ceviche, con ingredientes del litoral peruano. Aprende sobre cortes, equilibrio de sabores y acompañamientos.",
    "titeres": "Una función de títeres con personajes hechos a mano y pequeñas aventuras para público familiar. Al terminar, descubre cómo cobran vida detrás del teatrín.",
    "balcones": "Caminata para reconocer balcones, fachadas y detalles de las casonas del centro histórico. Incluye paradas para observar y fotografiar la arquitectura desde la vía pública.",
    "fotografia": "Exposición de fotografía sobre el mar, los oficios y la vida cotidiana del norte. Recorre la muestra y conversa sobre las historias que hay detrás de cada imagen.",
    "cajon": "Explora los golpes básicos del cajón peruano y practica patrones en grupo. Una sesión de iniciación centrada en escuchar, coordinar y crear ritmo juntos.",
    "pan": "Taller de amasado y horneado inspirado en la panadería tradicional del norte. Conoce los ingredientes, los tiempos de reposo y los gestos de un oficio cotidiano.",
    "huacas": "Visita interpretativa dedicada a los murales, colores y expresiones del mundo Moche. Se propone una observación respetuosa del patrimonio y de sus espacios protegidos.",
    "impro": "El público propone situaciones y el elenco las transforma en escenas improvisadas. Una noche de humor y creatividad donde cada historia se construye en el momento.",
    "festejo": "Presentación de festejo y percusión afroperuana con una breve introducción participativa al ritmo. Un encuentro para celebrar movimiento, música y memoria cultural.",
  };
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
          imageAsset: 'assets/images/events/${r[0]}.png',
          description:
              '${descriptions[r[0]]}\n\nEvento ficticio creado para explorar la aplicación. La fecha, el organizador, el precio y el programa son ilustrativos; no constituyen una convocatoria real. Imagen ilustrativa generada para la demo.',
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
            normalize('${e.title} ${e.venue} ${e.category}')
                .contains(normalize(query.trim())) &&
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
