import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app.dart';
import 'design.dart';
import 'event.dart';
import 'state.dart';
import 'access.dart';

class ProfileView extends StatelessWidget {
  final AppState state;
  const ProfileView({super.key, required this.state});
  @override
  Widget build(BuildContext context) => !state.loggedIn
      ? AccessPrompt(state: state, action: 'personalizar tu perfil e intereses')
      : ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Eyebrow('Tu propia forma de vivir Trujillo'),
            const SizedBox(height: 10),
            Text(
              'Este es tu espacio',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: ink,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 27,
                    backgroundColor: gold,
                    child: Icon(Icons.person_outline, size: 30, color: ink),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.loggedIn
                        ? 'Hola, ${state.name}'
                        : 'La cultura también es tuya.',
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      color: cream,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.loggedIn
                        ? '${state.saved.length} planes guardados · ${state.interests.length} intereses'
                        : 'Descubre, guarda y haz espacio para lo que te mueve.',
                    style: const TextStyle(
                      color: Color(0xFFCDD8CB),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (!state.loggedIn)
                    FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => LoginView(state: state),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: cream,
                        foregroundColor: ink,
                      ),
                      child: const Text('Entrar a mi espacio'),
                    )
                  else
                    TextButton(
                      onPressed: state.signOut,
                      style: TextButton.styleFrom(foregroundColor: cream),
                      child: const Text('Cerrar sesión'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Lo que te mueve',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Elige tus intereses. Tu feed se adapta a ti.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 16),
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
            const Divider(color: line),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Avisos de eventos cercanos',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'En Android, al consultar tu ubicación en la app. No rastrea en segundo plano.',
                style: TextStyle(fontSize: 12, color: muted),
              ),
              value: state.nearbyEnabled,
              onChanged: state.setNearby,
            ),
            const Divider(color: line),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF2E5D9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Para quienes crean cultura'),
                  const SizedBox(height: 10),
                  const Text(
                    'Tu evento merece\nencontrar a su gente.',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Prepara una propuesta para nuestra futura comunidad de organizadores.',
                    style: TextStyle(fontSize: 13, color: muted),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => OrganizerView(state: state),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Crear borrador de evento'),
                  ),
                ],
              ),
            ),
            if (state.drafts.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(
                'Mis borradores (${state.drafts.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              for (final d in state.drafts)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_note, color: terra),
                  title: Text(d['title'] as String),
                  subtitle: const Text(
                    'Guardado en este dispositivo · no publicado',
                  ),
                ),
            ],
            const SizedBox(height: 26),
            const WovenBand(),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'TRAMA  /  TRUJILLO, PERÚ',
                style: TextStyle(color: muted, fontSize: 10, letterSpacing: 2),
              ),
            ),
          ],
        );
}

class LoginView extends StatefulWidget {
  final AppState state;
  final bool initialRegister;
  final VoidCallback? onExplore;
  const LoginView({
    super.key,
    required this.state,
    this.initialRegister = false,
    this.onExplore,
  });
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController(),
      confirmation = TextEditingController();
  bool register = false, busy = false, obscure = true;
  String? error;
  static const accent = Color(0xFF8D1B1B);
  static const background = Color(0xFFF5F0E9);

  @override
  void initState() {
    super.initState();
    register = widget.initialRegister;
  }

  @override
  void dispose() {
    for (final c in [name, email, password, confirmation]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final entry = widget.onExplore != null;
    final state = widget.state;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await state.authenticate(
        email.text,
        password.text,
        register: register,
        displayName: name.text,
      );
      if (entry) {
        if (!state.interestsChosen && navigator.mounted) {
          await navigator.push<void>(
            MaterialPageRoute(builder: (_) => InterestsWelcome(state: state)),
          );
        }
      } else if (mounted) {
        navigator.pop(true);
      }
    } on StateError catch (e) {
      if (mounted) setState(() => error = e.message.toString());
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(
          () => error = switch (e.code) {
            'email-already-in-use' => 'Ese correo ya tiene una cuenta.',
            'weak-password' => 'Elige una contraseña más segura.',
            'too-many-requests' => 'Demasiados intentos. Prueba más tarde.',
            'network-request-failed' => 'Revisa tu conexión a internet.',
            _ => 'No pudimos acceder. Revisa tu correo y contraseña.',
          },
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'No pudimos acceder. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  InputDecoration decoration(String label, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: muted),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE0D4C8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE0D4C8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(primary: accent),
    ),
    child: Scaffold(
      backgroundColor: background,
      appBar: widget.onExplore == null
          ? AppBar(backgroundColor: background)
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AutofillGroup(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hub_outlined, color: accent, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'trama',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: ink,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'TRUJILLO, PERÚ',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Semantics(
                      label: 'Ilustración de la Plaza de Armas de Trujillo',
                      image: true,
                      child: Image.asset(
                        'assets/images/trujillo-login.png',
                        height: register ? 100 : 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    register ? 'Crear una cuenta' : 'Iniciar sesión',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    register
                        ? 'Haz espacio para lo que te mueve'
                        : 'Bienvenido de vuelta',
                    style: const TextStyle(color: muted, fontSize: 14),
                  ),
                  const SizedBox(height: 22),
                  Form(
                    key: form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (register) ...[
                          TextFormField(
                            key: const Key('auth-name'),
                            controller: name,
                            enabled: !busy,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.name],
                            textInputAction: TextInputAction.next,
                            decoration: decoration(
                              'Nombre completo',
                              Icons.person_outline,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Escribe tu nombre'
                                : null,
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          key: const Key('auth-email'),
                          controller: email,
                          enabled: !busy,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: decoration(
                            'Correo electrónico',
                            Icons.mail_outline,
                          ),
                          validator: (v) =>
                              v != null &&
                                  RegExp(
                                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                  ).hasMatch(v.trim())
                              ? null
                              : 'Escribe un correo válido',
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          key: const Key('auth-password'),
                          controller: password,
                          enabled: !busy,
                          obscureText: obscure,
                          enableSuggestions: false,
                          autocorrect: false,
                          autofillHints: [
                            register
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          textInputAction: register
                              ? TextInputAction.next
                              : TextInputAction.done,
                          onFieldSubmitted: (_) {
                            if (!register && !busy) submit();
                          },
                          decoration: decoration(
                            'Contraseña',
                            Icons.lock_outline,
                            suffix: IconButton(
                              tooltip: obscure
                                  ? 'Mostrar contraseña'
                                  : 'Ocultar contraseña',
                              onPressed: () =>
                                  setState(() => obscure = !obscure),
                              icon: Icon(
                                obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: muted,
                              ),
                            ),
                          ),
                          validator: (v) => (v?.length ?? 0) < 6
                              ? 'Usa al menos 6 caracteres'
                              : null,
                        ),
                        if (register) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            key: const Key('auth-confirmation'),
                            controller: confirmation,
                            enabled: !busy,
                            obscureText: obscure,
                            enableSuggestions: false,
                            autocorrect: false,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!busy) submit();
                            },
                            decoration: decoration(
                              'Confirmar contraseña',
                              Icons.lock_outline,
                            ),
                            validator: (v) => v != password.text
                                ? 'Las contraseñas no coinciden'
                                : null,
                          ),
                        ],
                        if (error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Text(
                              error!,
                              style: const TextStyle(color: accent),
                            ),
                          ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: busy ? null : submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            busy
                                ? 'Un momento…'
                                : register
                                ? 'Registrarme'
                                : 'Ingresar',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        register
                            ? '¿Ya tienes una cuenta?'
                            : '¿No tienes cuenta?',
                        style: const TextStyle(color: muted, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => setState(() {
                                register = !register;
                                error = null;
                                password.clear();
                                confirmation.clear();
                                form.currentState?.reset();
                              }),
                        child: Text(
                          register ? 'Inicia sesión aquí' : 'Regístrate aquí',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  if (widget.onExplore != null)
                    TextButton(
                      onPressed: busy ? null : widget.onExplore,
                      child: const Text(
                        'Explorar como invitado →',
                        style: TextStyle(color: muted),
                      ),
                    ),
                  if (!widget.state.firebaseReady)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Demo local · Usa datos de prueba. Tu cuenta se guarda solo en este dispositivo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class OrganizerView extends StatefulWidget {
  final AppState state;
  const OrganizerView({super.key, required this.state});
  @override
  State<OrganizerView> createState() => _OrganizerViewState();
}

class _OrganizerViewState extends State<OrganizerView> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(),
      organizer = TextEditingController(),
      venue = TextEditingController(),
      url = TextEditingController(),
      description = TextEditingController();
  String category = categories.first;
  DateTime? date;
  TimeOfDay? time;
  bool busy = false;
  @override
  void dispose() {
    for (final c in [title, organizer, venue, url, description]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Un nuevo encuentro')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Eyebrow('Espacio de organizadores'),
              const SizedBox(height: 12),
              Text(
                'Dale forma a tu evento',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'Este borrador se guarda solo en tu dispositivo. La publicación, revisión y promoción pagada estarán disponibles en una próxima etapa.',
                style: TextStyle(color: muted),
              ),
              const SizedBox(height: 24),
              input(title, 'Nombre del evento'),
              input(organizer, 'Organizador o institución'),
              input(venue, 'Lugar y dirección'),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => category = v!),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (d != null && mounted) setState(() => date = d);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  date == null
                      ? 'Elegir fecha'
                      : '${shortDate(date!)} ${date!.year}',
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 18, minute: 0),
                  );
                  if (t != null && mounted) setState(() => time = t);
                },
                icon: const Icon(Icons.schedule),
                label: Text(
                  time == null ? 'Elegir hora' : time!.format(context),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: url,
                decoration: const InputDecoration(
                  labelText: 'Enlace original (opcional)',
                  hintText: 'https://…',
                ),
                keyboardType: TextInputType.url,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final u = Uri.tryParse(v.trim());
                  return u != null && u.scheme == 'https' && u.host.isNotEmpty
                      ? null
                      : 'Usa un enlace https válido';
                },
              ),
              const SizedBox(height: 16),
              input(description, 'Descripción del evento', lines: 4),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: busy
                    ? null
                    : () async {
                        if (!form.currentState!.validate()) return;
                        if (date == null || time == null) {
                          toast(context, 'Elige fecha y hora para el evento.');
                          return;
                        }
                        final start = DateTime(
                          date!.year,
                          date!.month,
                          date!.day,
                          time!.hour,
                          time!.minute,
                        );
                        if (!start.isAfter(DateTime.now())) {
                          toast(
                            context,
                            'La fecha del evento debe ser futura.',
                          );
                          return;
                        }
                        setState(() => busy = true);
                        try {
                          await widget.state.saveDraft({
                            'title': title.text.trim(),
                            'organizer': organizer.text.trim(),
                            'venue': venue.text.trim(),
                            'sourceUrl': url.text.trim(),
                            'description': description.text.trim(),
                            'category': category,
                            'start': start.toIso8601String(),
                          });
                          if (context.mounted) {
                            Navigator.pop(context);
                            toast(
                              context,
                              'Borrador guardado en este dispositivo.',
                            );
                          }
                        } catch (_) {
                          if (context.mounted) {
                            toast(context, 'No se pudo guardar el borrador.');
                          }
                        } finally {
                          if (mounted) setState(() => busy = false);
                        }
                      },
                child: Text(busy ? 'Guardando…' : 'Guardar borrador'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget input(TextEditingController c, String label, {int lines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: c,
          maxLines: lines,
          decoration: InputDecoration(labelText: label),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Completa este campo' : null,
        ),
      );
}
