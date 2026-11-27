import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/supabase/supabase_client.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get currentUser => supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  AuthProvider() {
    _checkSession();
    supabase.auth.onAuthStateChange.listen((event) {
      switch (event.event) {
        case AuthChangeEvent.signedIn:
          _status = AuthStatus.authenticated;
        case AuthChangeEvent.signedOut:
          _status = AuthStatus.unauthenticated;
        default:
          break;
      }
      notifyListeners();
    });
  }

  void _checkSession() {
    final session = supabase.auth.currentSession;
    _status = session != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading();
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _setLoading();
    try {
      final response =
          await supabase.auth.signUp(email: email, password: password);
      if (response.user != null) {
        _status = AuthStatus.authenticated;
      } else {
        // Email konfirmasi diperlukan
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Cek email kamu untuk konfirmasi akun.';
      }
      notifyListeners();
      return response.user != null;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _status = AuthStatus.error;
    notifyListeners();
  }
}
