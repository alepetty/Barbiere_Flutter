import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // creo un istanza di fireAuth

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges(); // mi monitora il cambiamento dell'autenticazione

  Future<void> signIn(String email, String password) async { //future
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception("Errore durante l'accesso: ${e.toString()}");
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
