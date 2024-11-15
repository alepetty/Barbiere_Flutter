import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/Auth/Login.dart';
import 'views/Home/Home.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Controlla se l'utente è autenticato
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // Utente autenticato, vai alla schermata Home
          return Homepage();
        } else {
          // Utente non autenticato, mostra la schermata di Login
          return LoginPage();
        }
      },
    );
  }
}
