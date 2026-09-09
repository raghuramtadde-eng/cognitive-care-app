import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/sync_service.dart';

/// The only role that ever authenticates is the caregiver (see
/// supabase_schema.sql for the reasoning). This provider is the single
/// source of truth for that session — every screen decides what to show
/// based on `currentUser` being null or not.
class AuthProvider extends ChangeNotifier {
  SupabaseClient get _client => Supabase.instance.client;

  late final StreamSubscription<AuthState> _sub;
  bool _initialLoadDone = false;

  AuthProvider() {
    // currentSession is already restored synchronously from local storage
    // by supabase_flutter before this provider is constructed (see main.dart).
    _initialLoadDone = true;
    _sub = _client.auth.onAuthStateChange.listen((state) {
      notifyListeners();
      if (state.event == AuthChangeEvent.signedIn) {
        SyncService.instance.syncNow();
      }
    });
  }

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  bool get ready => _initialLoadDone;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  // The SDK clears the local session and fires `signedOut` synchronously
  // before it ever touches the network — the network call that follows only
  // revokes the refresh token server-side, which this offline-first app
  // doesn't depend on. Cap it so a slow/absent connection can't leave the
  // caregiver stuck on-screen waiting for a logout that already succeeded
  // locally.
  Future<void> signOut() => _client.auth
      .signOut()
      .timeout(const Duration(seconds: 2), onTimeout: () {});

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
