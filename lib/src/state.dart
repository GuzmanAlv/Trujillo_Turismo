import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'package:flutter/foundation.dart';

import 'storage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'event.dart';
import 'services.dart';

class AppState extends ChangeNotifier {
  AppState({LocalStore? store}) : prefs = store ?? PreferencesStore();
  static const live = bool.fromEnvironment('FIREBASE_ENABLED');
  static const mapsEnabled = bool.fromEnvironment('MAPS_ENABLED');
  final LocalStore prefs;
  final reminders = ReminderService();
  List<CulturalEvent> events = [];
  Set<String> saved = {},
      liked = {},
      reminderIds = {},
      interests = {'Danza', 'Arte'};
  List<Map<String, dynamic>> drafts = [];
  String? name, email, startupMessage;
  bool firebaseReady = false, nearbyEnabled = false;
  bool demoCatalog = true;
  bool interestsChosen = false;
  double? latitude, longitude;
  bool get loggedIn => name != null;
  Future<void> initialize() async {
    final anchorText = await prefs.getString('demoAnchor');
    final anchor = DateTime.tryParse(anchorText ?? '') ?? DateTime.now();
    await prefs.setString('demoAnchor', anchor.toIso8601String());
    events = demoEvents(anchor);
    saved = (await prefs.getStringList('saved') ?? []).toSet();
    liked = (await prefs.getStringList('liked') ?? []).toSet();
    reminderIds = (await prefs.getStringList('reminders') ?? []).toSet();
    interests = (await prefs.getStringList('interests') ?? ['Danza', 'Arte'])
        .toSet();
    name = await prefs.getString('demoName');
    email = await prefs.getString('demoEmail');
    interestsChosen = await prefs.getBool('interestsChosen') ?? false;
    nearbyEnabled = await prefs.getBool('nearby') ?? false;
    final storedDrafts = await prefs.getString('drafts');
    if (storedDrafts != null) {
      drafts = (jsonDecode(storedDrafts) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    try {
      await reminders.initialize();
    } catch (_) {
      startupMessage =
          'Los recordatorios del dispositivo no están disponibles.';
    }
    if (live) {
      try {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
            appId: String.fromEnvironment('FIREBASE_APP_ID'),
            messagingSenderId: String.fromEnvironment('FIREBASE_SENDER_ID'),
            projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
          ),
        );
        firebaseReady = true;
        final user = FirebaseAuth.instance.currentUser;
        name = user == null ? null : (user.displayName ?? 'Explorador');
        email = user?.email;
        await refreshEvents();
      } catch (_) {
        startupMessage =
            'No se pudo conectar con Firebase. Mostramos la agenda de ejemplo.';
      }
    }
  }

  Future<void> refreshEvents() async {
    if (firebaseReady) {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('published', isEqualTo: true)
          .get();
      events = snapshot.docs
          .map((d) => CulturalEvent.fromJson(d.id, d.data()))
          .toList();
      demoCatalog = false;
    }
    notifyListeners();
  }

  Future<void> toggleSaved(String id) async {
    if (!loggedIn) return;
    if (!saved.add(id)) {
      saved.remove(id);
      await reminders.cancel(id);
      reminderIds.remove(id);
      await prefs.setStringList('reminders', reminderIds.toList());
    }
    await prefs.setStringList('saved', saved.toList());
    notifyListeners();
  }

  Future<void> toggleLiked(String id) async {
    if (!loggedIn) return;
    if (!liked.add(id)) liked.remove(id);
    await prefs.setStringList('liked', liked.toList());
    notifyListeners();
  }

  Future<void> toggleInterest(String category) async {
    if (!loggedIn) return;
    if (!interests.add(category)) interests.remove(category);
    await prefs.setStringList('interests', interests.toList());
    notifyListeners();
  }

  Future<bool> toggleReminder(CulturalEvent event) async {
    if (!loggedIn) return false;
    if (reminderIds.contains(event.id)) {
      await reminders.cancel(event.id);
      reminderIds.remove(event.id);
    } else {
      if (!await reminders.schedule(event)) return false;
      saved.add(event.id);
      reminderIds.add(event.id);
      await prefs.setStringList('saved', saved.toList());
    }
    await prefs.setStringList('reminders', reminderIds.toList());
    notifyListeners();
    return true;
  }

  Future<void> finishInterests() async {
    if (!loggedIn) return;
    await prefs.setBool('interestsChosen', true);
    interestsChosen = true;
    notifyListeners();
  }

  Future<void> demoLogin(String displayName) async {
    name = displayName.trim().isEmpty ? 'Explorador' : displayName.trim();
    await prefs.setString('demoName', name!);
    notifyListeners();
  }

  Future<void> authenticate(
    String emailInput,
    String password, {
    required bool register,
    required String displayName,
  }) async {
    if (!firebaseReady) {
      await authenticateDemo(
        emailInput,
        password,
        register: register,
        displayName: displayName,
      );
      return;
    }
    final credential = register
        ? await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailInput.trim(),
            password: password,
          )
        : await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailInput.trim(),
            password: password,
          );
    if (register) await credential.user!.updateDisplayName(displayName.trim());
    name = credential.user!.displayName ?? displayName;
    email = credential.user!.email;
    notifyListeners();
  }

  // Demo credentials stay on this device; Firebase remains the production path.
  Future<void> authenticateDemo(
    String emailInput,
    String password, {
    required bool register,
    required String displayName,
  }) async {
    final normalized = emailInput.trim().toLowerCase();
    final encoded = await prefs.getString('demoAccounts');
    final accounts = encoded == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(encoded) as Map);
    if (register) {
      if (accounts.containsKey(normalized)) {
        throw StateError('Este correo ya está registrado en este dispositivo.');
      }
      final salt = base64UrlEncode(
        List<int>.generate(24, (_) => Random.secure().nextInt(256)),
      );
      accounts[normalized] = {
        'name': displayName.trim(),
        'salt': salt,
        'hash': sha256.convert(utf8.encode('$salt:$password')).toString(),
      };
      await prefs.setString('demoAccounts', jsonEncode(accounts));
    } else {
      final account = accounts[normalized] as Map<String, dynamic>?;
      if (account == null ||
          account['hash'] !=
              sha256
                  .convert(utf8.encode('${account['salt']}:$password'))
                  .toString()) {
        throw StateError(
          'Correo o contraseña incorrectos. Si aún no tienes una cuenta demo, regístrate aquí.',
        );
      }
    }
    final account = accounts[normalized] as Map<String, dynamic>;
    // Keep each demo account's plans and preferences separate on the device.
    await _savePersonalData();
    email = normalized;
    await _loadPersonalData();
    name = account['name'] as String;
    await prefs.setString('demoName', name!);
    await prefs.setString('demoEmail', email!);
    notifyListeners();
  }

  String get _personalKey => 'demoPersonal:${email ?? 'legacy'}';

  Future<void> _savePersonalData() async {
    await prefs.setString(
      _personalKey,
      jsonEncode({
        'saved': saved.toList(),
        'liked': liked.toList(),
        'interests': interests.toList(),
        'drafts': drafts,
        'interestsChosen': interestsChosen,
      }),
    );
  }

  Future<void> _loadPersonalData() async {
    final encoded = await prefs.getString(_personalKey);
    final data = encoded == null
        ? <String, dynamic>{}
        : jsonDecode(encoded) as Map<String, dynamic>;
    saved = Set<String>.from(data['saved'] as List? ?? []);
    liked = Set<String>.from(data['liked'] as List? ?? []);
    interests = Set<String>.from(
      data['interests'] as List? ?? ['Danza', 'Arte'],
    );
    drafts = (data['drafts'] as List? ?? [])
        .map((d) => Map<String, dynamic>.from(d as Map))
        .toList();
    interestsChosen = data['interestsChosen'] as bool? ?? false;
    // Pending device notifications belong to the session that scheduled them.
    reminderIds = {};
    nearbyEnabled = false;
    await prefs.setStringList('saved', saved.toList());
    await prefs.setStringList('liked', liked.toList());
    await prefs.setStringList('interests', interests.toList());
    await prefs.setString('drafts', jsonEncode(drafts));
    await prefs.setBool('interestsChosen', interestsChosen);
    await prefs.setBool('nearby', false);
    await prefs.setStringList('reminders', []);
  }

  Future<void> signOut() async {
    if (firebaseReady) await FirebaseAuth.instance.signOut();
    if (!firebaseReady) {
      await _savePersonalData();
      for (final id in reminderIds) {
        await reminders.cancel(id);
      }
      reminderIds = {};
      await prefs.setStringList('reminders', []);
      nearbyEnabled = false;
      await prefs.setBool('nearby', false);
    }
    name = null;
    email = null;
    await prefs.remove('demoName');
    await prefs.remove('demoEmail');
    notifyListeners();
  }

  Future<void> locate() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Activa la ubicación de tu dispositivo.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError(
        'No tenemos permiso de ubicación. Puedes seguir explorando todos los eventos.',
      );
    }
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
    latitude = p.latitude;
    longitude = p.longitude;
    notifyListeners();
    if (loggedIn && nearbyEnabled) {
      await reminders.nearby(
        events
            .where(
              (e) =>
                  e.start.isAfter(DateTime.now()) &&
                  e.distanceFrom(latitude!, longitude!) <= 5,
            )
            .toList(),
      );
    }
  }

  Future<void> setNearby(bool enabled) async {
    if (!loggedIn) return;
    nearbyEnabled = enabled;
    await prefs.setBool('nearby', enabled);
    notifyListeners();
  }

  Future<void> saveDraft(Map<String, dynamic> draft) async {
    if (!loggedIn) return;
    drafts.add({...draft, 'createdAt': DateTime.now().toIso8601String()});
    await prefs.setString('drafts', jsonEncode(drafts));
    notifyListeners();
  }
}
