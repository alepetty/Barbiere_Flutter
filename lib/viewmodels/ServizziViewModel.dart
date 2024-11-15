import 'package:barberflutter/models/Cliente.dart';
import 'package:barberflutter/models/Prenotazione/Servizio.dart';
import 'package:flutter/cupertino.dart';

import '../repositories/ClientiRepository.dart';
import '../repositories/PrenotazioniRepository.dart';
import '../repositories/Servizirepository.dart';

class ServiziViewmodel extends ChangeNotifier {

  final Servizirepository _serviziRepository = Servizirepository();

  List<ServizioModel> _servizi = [];

  List<ServizioModel> get servizi => _servizi;

  // Funzione per caricare le prenotazioni utilizzando il repository
  Future<void> getServizzi(String uid) async {
    _servizi.clear();

    await _serviziRepository.getServizi(uid, (List<ServizioModel> result) {
      _servizi = result;

    });
    notifyListeners();
  }
}