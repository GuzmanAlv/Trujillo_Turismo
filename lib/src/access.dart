import 'package:flutter/material.dart';

import 'design.dart';
import 'event.dart';
import 'profile.dart';
import 'state.dart';

/// Authentication is optional for discovery; personal actions resume after login.
Future<bool> requireAccess(
  BuildContext context,
  AppState state,
  String action,
) async {
  if (state.loggedIn) return true;
  final proceed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Haz espacio para tus planes'),
      content: Text('Inicia sesión o crea una cuenta para $action.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Seguir explorando'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Entrar a mi espacio'),
        ),
      ],
    ),
  );
  if (proceed != true || !context.mounted) return false;
  await openAccess(context, state);
  return state.loggedIn;
}

Future<void> openAccess(
  BuildContext context,
  AppState state, {
  bool register = false,
}) async {
  final navigator = Navigator.of(context);
  await navigator.push<bool>(
    MaterialPageRoute(
      builder: (_) => LoginView(state: state, initialRegister: register),
    ),
  );
  if (state.loggedIn && !state.interestsChosen && navigator.mounted) {
    await navigator.push<void>(
      MaterialPageRoute(builder: (_) => InterestsWelcome(state: state)),
    );
  }
}

class AccessGate extends StatefulWidget {
  final AppState state;
  final Widget Function() builder;
  const AccessGate({super.key, required this.state, required this.builder});

  @override
  State<AccessGate> createState() => _AccessGateState();
}

class _AccessGateState extends State<AccessGate> {
  bool exploring = false;
  late bool wasLoggedIn = widget.state.loggedIn;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(changed);
  }

  void changed() {
    if (wasLoggedIn && !widget.state.loggedIn) exploring = false;
    wasLoggedIn = widget.state.loggedIn;
    setState(() {});
  }

  @override
  void dispose() {
    widget.state.removeListener(changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.state.loggedIn || exploring
      ? widget.builder()
      : LoginView(
          state: widget.state,
          onExplore: () => setState(() => exploring = true),
        );
}

class AccessPrompt extends StatelessWidget {
  final AppState state;
  final String action;
  const AccessPrompt({super.key, required this.state, required this.action});

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bookmark_border_rounded, color: terra, size: 48),
          const SizedBox(height: 20),
          Text(
            'Tus planes, en tu espacio',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Inicia sesión o crea una cuenta para $action.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => openAccess(context, state),
            child: const Text('Entrar a mi espacio'),
          ),
        ],
      ),
    ),
  );
}

class InterestsWelcome extends StatelessWidget {
  final AppState state;
  const InterestsWelcome({super.key, required this.state});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: ListenableBuilder(
      listenable: state,
      builder: (context, _) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(28),
            children: [
              const Eyebrow('Hagamos espacio a lo que te mueve'),
              const SizedBox(height: 16),
              Text(
                '¿Qué te gustaría descubrir?',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 14),
              const Text(
                'Elige tus intereses para personalizar tus recomendaciones. Puedes cambiarlos después en Mi perfil.',
                style: TextStyle(color: muted),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < categories.length; i++)
                    FilterChip(
                      label: Text(categories[i]),
                      avatar: Icon(categoryIcons[i], size: 18),
                      selected: state.interests.contains(categories[i]),
                      onSelected: (_) => state.toggleInterest(categories[i]),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () async {
                  await state.finishInterests();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Empezar a descubrir'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
