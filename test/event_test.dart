import 'package:flutter_test/flutter_test.dart';
import 'package:trujillo_cultura/src/event.dart';
import 'package:trujillo_cultura/src/state.dart';
import 'memory_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final events = demoEvents(DateTime(2026, 10, 19));
  test(
    'Accent insensitive search composes with category, date and free filters',
    () {
      final result = filterEvents(
        events,
        query: 'musica',
        category: 'Música',
        freeOnly: true,
        day: DateTime(2026, 10, 27),
      );
      expect(result.map((e) => e.id), ['musica']);
      expect(filterEvents(events, query: 'no such event'), isEmpty);
    },
  );
  test('Recommendations rank interests and likes, with chronological ties', () {
    expect(
      filterEvents(events, interests: {'Teatro'}).first.category,
      'Teatro',
    );
    expect(
      filterEvents(
        events,
        liked: {'jazz'},
      ).take(2).every((e) => e.category == 'Música'),
      isTrue,
    );
  });
  test('Distance filter excludes Huanchaco from downtown 5 km radius', () {
    final result = filterEvents(events, lat: -8.1116, lng: -79.0287, radius: 5);
    expect(result.any((e) => e.id == 'marinera'), isTrue);
    expect(result.any((e) => e.id == 'sabores'), isFalse);
    expect(events.first.distanceFrom(-8.1116, -79.0287), closeTo(0, .001));
  });
  test(
    'Agenda, interests, likes, profile and drafts survive state recreation',
    () async {
      final store = MemoryStore();
      final a = AppState(store: store);
      await a.initialize();
      await a.toggleSaved('marinera');
      await a.toggleLiked('jazz');
      await a.toggleInterest('Teatro');
      await a.demoLogin('Ana');
      await a.saveDraft({'title': 'Mi evento'});
      final b = AppState(store: store);
      await b.initialize();
      expect(b.saved, contains('marinera'));
      expect(b.liked, contains('jazz'));
      expect(b.interests, contains('Teatro'));
      expect(b.name, 'Ana');
      expect(b.drafts.single['title'], 'Mi evento');
      expect(b.events.first.start, a.events.first.start);
      await b.toggleSaved('marinera');
      final c = AppState(store: store);
      await c.initialize();
      expect(c.saved, isEmpty);
    },
  );
}
