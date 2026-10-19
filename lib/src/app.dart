import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'design.dart';
import 'event.dart';
import 'state.dart';
import 'map_view.dart';
import 'profile.dart';

void toast(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
Future<void> openExternal(BuildContext context, Uri uri) async {
  try {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      toast(context, 'No se pudo abrir el enlace.');
    }
  } catch (_) {
    if (context.mounted) toast(context, 'No se pudo abrir el enlace.');
  }
}

class TramaApp extends StatelessWidget {
  final AppState state;
  const TramaApp({super.key, required this.state});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Trama · Cultura que conecta',
    debugShowCheckedModeBanner: false,
    theme: tramaTheme(),
    home: HomeShell(state: state),
  );
}

class HomeShell extends StatefulWidget {
  final AppState state;
  const HomeShell({super.key, required this.state});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) {
      final state = widget.state;
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SafeArea(
              child: Column(
                children: [
                    if (state.demoCatalog)
                    Container(
                      width: double.infinity,
                      color: const Color(0xFFF0EBDF),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: const Text(
                        'MODO DEMO  ·  Eventos ilustrativos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1,
                          color: muted,
                        ),
                      ),
                    ),
                  if (state.startupMessage != null)
                    MaterialBanner(
                      content: Text(state.startupMessage!),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              setState(() => state.startupMessage = null),
                          child: const Text('Entendido'),
                        ),
                      ],
                    ),
                  Expanded(
                    child: IndexedStack(
                      index: tab,
                      children: [
                        DiscoverView(
                          state: state,
                          onProfile: () => setState(() => tab = 3),
                        ),
                        MapView(state: state),
                        AgendaView(state: state),
                        ProfileView(state: state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: line)),
          ),
          child: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (i) => setState(() => tab = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Descubrir',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map),
                label: 'Cerca de mí',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Mi agenda',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Mi perfil',
              ),
            ],
          ),
        ),
      );
    },
  );
}

class DiscoverView extends StatefulWidget {
  final AppState state;
  final VoidCallback onProfile;
  const DiscoverView({super.key, required this.state, required this.onProfile});
  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  String query = '';
  String? category;
  bool free = false, upcoming = true;
  DateTime? date;
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final events = filterEvents(
      s.events
          .where((e) => !upcoming || e.start.isAfter(DateTime.now()))
          .toList(),
      query: query,
      category: category,
      freeOnly: free,
      day: date,
      interests: s.interests,
      liked: s.liked,
    );
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await s.refreshEvents();
        } catch (_) {
          if (context.mounted) {
            toast(
              context,
              'No pudimos actualizar la agenda. Inténtalo de nuevo.',
            );
          }
        }
      },
      child: CustomScrollView(
        key: const PageStorageKey('feed'),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: terra,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.hub_outlined,
                        color: cream,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Text(
                        'trama',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 29,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                          color: ink,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.location_on_outlined,
                      color: terra,
                      size: 17,
                    ),
                    const SizedBox(width: 3),
                    const Flexible(
                      child: Text(
                        'Trujillo, Perú',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: widget.onProfile,
                      tooltip: 'Tu perfil e intereses',
                      icon: const Icon(Icons.person_outline_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFECEBDD),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Eyebrow('La cultura vive aquí'),
                const SizedBox(height: 10),
                Text(
                  'Encuentra tu\npróximo encuentro.',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Toda la cultura de Trujillo, en un solo lugar.',
                  style: TextStyle(color: muted, fontSize: 14),
                ),
                const SizedBox(height: 23),
                TextField(
                  controller: search,
                  onChanged: (v) => setState(() => query = v),
                  decoration: InputDecoration(
                    hintText: '¿Qué te gustaría descubrir?',
                    prefixIcon: const Icon(Icons.search_rounded, color: muted),
                    suffixIcon: IconButton(
                      tooltip: 'Filtros',
                      onPressed: showFilters,
                      icon: Badge(
                        isLabelVisible: free || date != null,
                        child: const Icon(Icons.tune_rounded, color: terra),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  categoryChip('Para ti', null, Icons.auto_awesome_outlined),
                  for (int i = 0; i < categories.length; i++)
                    categoryChip(
                      categories[i],
                      categories[i],
                      categoryIcons[i],
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (free || date != null)
                    Wrap(
                      spacing: 8,
                      children: [
                        if (free)
                          InputChip(
                            label: const Text('Ingreso libre'),
                            onDeleted: () => setState(() => free = false),
                          ),
                        if (date != null)
                          InputChip(
                            label: Text(shortDate(date!)),
                            onDeleted: () => setState(() => date = null),
                          ),
                      ],
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category == null
                              ? 'Hecho para tus gustos'
                              : 'Descubre $category',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        '${events.length} planes',
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    category == null
                        ? 'Inspirado en tus intereses y lo que te gusta.'
                        : 'Conecta con nuevas experiencias.',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          if (events.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(
                title: 'Hay más por descubrir',
                body: 'Prueba otra categoría, fecha o búsqueda.',
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.builder(
              itemCount: events.length,
              itemBuilder: (context, i) =>
                  EventCard(event: events[i], state: s, featured: i == 0),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  WovenBand(),
                  SizedBox(height: 16),
                  Text(
                    'Hecho para encontrarnos. Hecho en Trujillo.',
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryChip(String title, String? value, IconData icon) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(title),
      avatar: Icon(icon, size: 16, color: category == value ? cream : ink),
      selected: category == value,
      showCheckmark: false,
      selectedColor: ink,
      backgroundColor: cream,
      side: const BorderSide(color: line),
      labelStyle: TextStyle(
        fontSize: 12,
        color: category == value ? cream : ink,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      onSelected: (_) => setState(() => category = value),
    ),
  );
  void showFilters() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tu plan, a tu manera',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Solo ingreso libre'),
                  value: free,
                  onChanged: (v) {
                    setState(() => free = v);
                    update(() {});
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Solo próximos eventos'),
                  value: upcoming,
                  onChanged: (v) {
                    setState(() => upcoming = v);
                    update(() {});
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(
                    date == null ? 'Cualquier fecha' : shortDate(date!),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: date ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2040),
                    );
                    if (selected != null) {
                      setState(() => date = selected);
                      update(() {});
                    }
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Ver eventos'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      date = null;
                      free = false;
                      category = null;
                      upcoming = true;
                      query = '';
                      search.clear();
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Restablecer filtros'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final CulturalEvent event;
  final AppState state;
  final bool featured;
  const EventCard({
    super.key,
    required this.event,
    required this.state,
    this.featured = false,
  });
  @override
  Widget build(BuildContext context) {
    final e = event;
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            onTap: () => showEvent(context, e, state),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(21),
              ),
              child: Stack(
                children: [
                  EventArt(kind: e.art, height: 240),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: cream,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        e.category.toUpperCase(),
                        style: const TextStyle(
                          color: ink,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      width: 51,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: cream,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${e.start.day}',
                            style: const TextStyle(
                              fontSize: 23,
                              height: 1,
                              fontWeight: FontWeight.w800,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            months[e.start.month - 1].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: terra,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 14,
                    child: Text(
                      featured
                          ? 'UN ENCUENTRO PARA TI'
                          : 'VIVE LA CULTURA LOCAL',
                      style: const TextStyle(
                        color: cream,
                        letterSpacing: 2,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.groups_outlined, size: 14, color: terra),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        e.organizer,
                        style: const TextStyle(fontSize: 11, color: muted),
                      ),
                    ),
                    Text(
                      e.priceLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => showEvent(context, e, state),
                  child: Text(
                    e.title.replaceAll('\n', ' '),
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ink,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: muted,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        e.venue,
                        style: const TextStyle(fontSize: 12, color: muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${shortDate(e.start)} · ${hour(e.start)} h',
                  style: const TextStyle(
                    color: terra,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: line),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Me gusta',
                      onPressed: () => state.toggleLiked(e.id),
                      icon: Icon(
                        state.liked.contains(e.id)
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: state.liked.contains(e.id) ? terra : muted,
                        size: 22,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copiar evento',
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text:
                                '${e.title.replaceAll('\n', ' ')}\n${shortDate(e.start)} ${hour(e.start)} · ${e.venue}\n${e.sourceUrl.isEmpty ? 'Evento ilustrativo de Trama (demo)' : e.sourceUrl}',
                          ),
                        );
                        if (context.mounted) {
                          toast(context, 'Evento copiado para compartir.');
                        }
                      },
                      icon: const Icon(
                        Icons.ios_share_outlined,
                        size: 20,
                        color: muted,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => state.toggleSaved(e.id),
                      icon: Icon(
                        state.saved.contains(e.id)
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 19,
                      ),
                      label: Text(
                        state.saved.contains(e.id) ? 'En tu agenda' : 'Guardar',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showEvent(BuildContext context, CulturalEvent event, AppState state) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => EventDetail(event: event, state: state),
    ),
  );
}

class EventDetail extends StatelessWidget {
  final CulturalEvent event;
  final AppState state;
  const EventDetail({super.key, required this.event, required this.state});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) {
      final e = event;
      final related = state.events
          .where((v) => v.id != e.id && v.category == e.category)
          .toList();
      return Scaffold(
        appBar: AppBar(title: const Text('El próximo encuentro')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              children: [
                EventArt(kind: e.art, height: 280),
                const WovenBand(),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Eyebrow(e.category),
                      const SizedBox(height: 10),
                      Text(
                        e.title.replaceAll('\n', ' '),
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Por ${e.organizer}',
                        style: const TextStyle(color: muted),
                      ),
                      const SizedBox(height: 20),
                      detailRow(
                        Icons.calendar_month_outlined,
                        '${shortDate(e.start)} de ${e.start.year} · ${hour(e.start)} h',
                      ),
                      detailRow(Icons.location_on_outlined, e.venue),
                      detailRow(
                        Icons.confirmation_number_outlined,
                        e.priceLabel,
                      ),
                      const SizedBox(height: 18),
                      Text(e.description),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => state.toggleSaved(e.id),
                        icon: Icon(
                          state.saved.contains(e.id)
                              ? Icons.bookmark_added
                              : Icons.bookmark_add_outlined,
                        ),
                        label: Text(
                          state.saved.contains(e.id)
                              ? 'Quitar de mi agenda'
                              : 'Agregar a mi agenda',
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            final ok = await state.toggleReminder(e);
                            if (context.mounted) {
                              toast(
                                context,
                                ok
                                    ? (state.reminderIds.contains(e.id)
                                          ? 'Recordatorio programado aproximadamente una hora antes.'
                                          : 'Recordatorio desactivado.')
                                    : 'Disponible en Android con notificaciones permitidas y al menos una hora de anticipación.',
                              );
                            }
                          } catch (_) {
                            if (context.mounted) {
                              toast(
                                context,
                                'No se pudo programar el recordatorio.',
                              );
                            }
                          }
                        },
                        icon: Icon(
                          state.reminderIds.contains(e.id)
                              ? Icons.notifications_active
                              : Icons.notifications_none,
                        ),
                        label: Text(
                          state.reminderIds.contains(e.id)
                              ? 'Desactivar recordatorio'
                              : 'Recordarme una hora antes',
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => openExternal(
                          context,
                          Uri.parse(
                            'https://www.google.com/maps/dir/?api=1&destination=${e.latitude},${e.longitude}',
                          ),
                        ),
                        icon: const Icon(Icons.directions_outlined),
                        label: const Text('Cómo llegar con Google Maps'),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDE2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Eyebrow('Información de origen', color: ink),
                            const SizedBox(height: 7),
                            Text(e.source),
                            if (e.sourceUrl.isNotEmpty)
                              TextButton(
                                onPressed: () => openExternal(
                                  context,
                                  Uri.parse(e.sourceUrl),
                                ),
                                child: const Text('Ver publicación original ↗'),
                              )
                            else
                              const Text(
                                'Contenido de demostración. No es un evento anunciado.',
                                style: TextStyle(fontSize: 12, color: muted),
                              ),
                          ],
                        ),
                      ),
                      if (related.isNotEmpty) ...[
                        const SizedBox(height: 26),
                        Text(
                          'También va contigo',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 14),
                        for (final r in related)
                          EventCard(event: r, state: state),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  Widget detailRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, color: terra, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class AgendaView extends StatefulWidget {
  final AppState state;
  const AgendaView({super.key, required this.state});
  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? selected;
  @override
  Widget build(BuildContext context) {
    final saved =
        widget.state.events
            .where((e) => widget.state.saved.contains(e.id))
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    final visible = saved
        .where((e) => selected == null || sameDay(e.start, selected!))
        .toList();
    final count = DateTime(month.year, month.month + 1, 0).day;
    final offset = month.weekday - 1;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Eyebrow('Hazle espacio a la cultura'),
        const SizedBox(height: 10),
        Text(
          'Tu agenda cultural',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        const Text(
          'Los planes que no te quieres perder.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: line),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Mes anterior',
                    onPressed: () => setState(
                      () => month = DateTime(month.year, month.month - 1),
                    ),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      '${months[month.month - 1].toUpperCase()} ${month.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Mes siguiente',
                    onPressed: () => setState(
                      () => month = DateTime(month.year, month.month + 1),
                    ),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              Row(
                children: [
                  for (final d in ['L', 'M', 'M', 'J', 'V', 'S', 'D'])
                    Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(color: muted, fontSize: 11),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                ),
                itemCount: ((count + offset) / 7).ceil() * 7,
                itemBuilder: (context, i) {
                  final day = i - offset + 1;
                  if (day < 1 || day > count) return const SizedBox.shrink();
                  final d = DateTime(month.year, month.month, day);
                  final active = selected != null && sameDay(selected!, d);
                  final hasEvent = saved.any((e) => sameDay(e.start, d));
                  return Semantics(
                    button: true,
                    label:
                        '$day ${months[month.month - 1]}${hasEvent ? ', evento guardado' : ''}',
                    child: InkWell(
                      onTap: () => setState(() => selected = active ? null : d),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: active
                              ? terra
                              : sameDay(d, DateTime.now())
                              ? const Color(0xFFF5EDE5)
                              : null,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontWeight: hasEvent
                                    ? FontWeight.w800
                                    : FontWeight.normal,
                                color: active ? cream : ink,
                              ),
                            ),
                            if (hasEvent)
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  color: active ? cream : terra,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                selected == null
                    ? 'Tus encuentros guardados'
                    : 'Planes del ${shortDate(selected!)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (selected != null)
              TextButton(
                onPressed: () => setState(() => selected = null),
                child: const Text('Ver todos'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (visible.isEmpty)
          const EmptyState(
            title: 'Tu próximo plan empieza aquí',
            body: 'Guarda un evento desde Descubrir para verlo en tu agenda.',
            icon: Icons.bookmark_border,
          ),
        for (final e in visible) EventCard(event: e, state: widget.state),
      ],
    );
  }
}

