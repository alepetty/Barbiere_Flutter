 import 'package:barberflutter/ui/theme.dart';
import 'package:barberflutter/viewmodels/AuthViewModel.dart';
import 'package:barberflutter/viewmodels/CalendarViewModel.dart';
import 'package:barberflutter/viewmodels/ClientiViewModel.dart';
import 'package:barberflutter/viewmodels/PrenotazioniViewModel.dart';
import 'package:barberflutter/viewmodels/ServizziViewModel.dart';
import 'package:barberflutter/viewmodels/TurniViewModel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AuthWrapper.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CalendarViewModel()),
        ChangeNotifierProvider(create: (_) => PrenotazioniViewModel()),
        ChangeNotifierProvider(create: (_) => TurniViewModel()),
        ChangeNotifierProvider(create: (_) => ServiziViewmodel()),
        ChangeNotifierProvider(create: (_) => ClientiViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: darkTheme,
      home:AuthWrapper(),
    );
  }
}

