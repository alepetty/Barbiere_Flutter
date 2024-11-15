import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/AuthService.dart';

/*
ChangeNotifier è una classe Flutter che fornisce la capacità di notificare
i listener ogni volta che lo stato cambia. Questo è utile per il pattern MVVM,
poiché le View possono ascoltare i cambiamenti nel ViewModel e aggiornarsi automaticamente.
 */

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;

  // Ascolta i cambiamenti di stato di autenticazione
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // Effettua il login
  Future<void> login(String email, String password) async {
    try {
      await _authService.signIn(email, password);
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners(); // Notifica la View di aggiornarsi
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Effettua il logout
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
