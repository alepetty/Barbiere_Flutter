import 'package:barberflutter/models/Day.dart';
import 'package:barberflutter/repositories/UserRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../models/Prenotazione/Prenoatzione.dart';
import '../models/Prenotazione/Prenotazione_completa.dart';
import '../repositories/PrenotazioniRepository.dart';

class PrenotazioniViewModel extends ChangeNotifier {

  final Prenotazionirepository _prenotazioniRepository = Prenotazionirepository();
  final UserRepository _userRepository= UserRepository();
  List<PrenotazioneCompleta> _prenotazioni = [];

  List<PrenotazioneCompleta> get prenotazioni => _prenotazioni;


  Future<void> checkStorico(String uid) async {
    await _userRepository.controllaAggiornamentoStorico(uid);
  }

  // Funzione per caricare le prenotazioni utilizzando il repository
  Future<void> loadPrenotazioniConDettagli(String uid, DateTime date) async {
    _prenotazioni.clear();

    await _prenotazioniRepository.getPrenotazioniConDettagli(uid, date, (List<PrenotazioneCompleta> result) {
      _prenotazioni = result;
      notifyListeners();
    });
  }

  Future<DayModel?> getDay(String uid, DateTime data, {Function(DayModel)? onSuccess}) async {
    DayModel? day = await _prenotazioniRepository.getDayData(uid, data);

    if (day != null) {
      if (onSuccess != null) {

        onSuccess(day);
      }
      return day;
    } else {
      print("Nessun dato trovato per il giorno specificato.");
      return null;
    }
  }


  Future<void> deletePrenotazione(String uid, DateTime date, PrenotazioneCompleta prenotazione,Function onUpdate) async {
    await _prenotazioniRepository.deletePrenotazione(uid, date, prenotazione,onUpdate);
    _prenotazioni.removeWhere((prenotazione) => prenotazione.prenotazione.id == prenotazione.prenotazione.id);
    notifyListeners();
  }
  Future<void> createPrenotazione({
    required String uid,
    required PrenotazioneModel prenotazione,
    required Function onSuccess,
    required Function onUpdate,
  }) async {
    try {
      // Chiama la funzione createPrenotazione del repository
      await _prenotazioniRepository.createPrenotazione(
        uid: uid,
        prenotazione: prenotazione,
        onSuccess: onSuccess,
        onUpdate: onUpdate,
      );
    } catch (e) {
      print("Errore durante la creazione della prenotazione nel ViewModel: $e");
    }
  }
}



