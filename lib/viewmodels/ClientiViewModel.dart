import 'package:barberflutter/models/Cliente.dart';
import 'package:flutter/cupertino.dart';

import '../repositories/ClientiRepository.dart';

import 'package:firebase_auth/firebase_auth.dart';



class ClientiViewModel extends ChangeNotifier {
  final ClientiRepository _clientiRepository = ClientiRepository();

  bool _isLoaded = false; // Flag per tracciare se i dati sono già stati caricati

  List<ClienteModel> _clienti = [];
  List<ClienteModel> get clienti => _clienti;

  ClienteModel? _selectedClient;
  ClienteModel? get selectedClient => _selectedClient;

  int? _numeroPrenotazioni;
  int? get numeroPrenotazioni => _numeroPrenotazioni;

  List<Map<String, dynamic>> _storicoServizi = [];
  List<Map<String, dynamic>> get storicoServizi => _storicoServizi;


  Future<void> getClienti(String uid) async {
    _clienti.clear(); // Pulisce la lista esistente

    await _clientiRepository.getClienti(uid, (List<ClienteModel> result) {
      _clienti = result;
    });

    notifyListeners();  // Notifica alla UI che i dati sono cambiati
  }

  Future<void> addClient({
    required String uid,
    required String nome,
    required String cognome,
    required String telefono,
  }) async {
    await _clientiRepository.createClient(
      uid: uid,
      nome: nome,
      cognome: cognome,
      telefono: telefono,
      onSuccess: () async {
        // Dopo aver creato il cliente, aggiorna la lista dei clienti
        await getClienti(uid);
        notifyListeners();
      },
    );
  }




  // Aggiornamento cliente
  Future<void> updateClient({
    required String id,
    required String nome,
    required String cognome,
    required String telefono,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _clientiRepository.updateClient(
        uid: uid,
        clientId: id,
        nome: nome,
        cognome: cognome,
        telefono: telefono,
      );
      await getClienti(uid); // Aggiorna la lista dopo l'aggiornamento
      notifyListeners();
    }
  }

  // Eliminazione cliente
  Future<void> deleteClient(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _clientiRepository.deleteClient(
        uid: uid,
        clientId: id,
      );
      await getClienti(uid); // Aggiorna la lista dopo l'eliminazione
      notifyListeners();
    }
  }


  Future<void> fetchNumeroPrenotazioni(String uid, String clienteId) async {
    try {
      final result = await _clientiRepository.getNumeroPrenotazioni(uid, clienteId);
      if (result != null) {
        _numeroPrenotazioni = result;
        notifyListeners();
      } else {
        throw Exception("Numero di prenotazioni non trovato.");
      }
    } catch (e) {
      print("Errore nel ViewModel: $e");
    }
  }


  Future<void> fetchStoricoServizi(String uid, String clienteId) async {
    try {
      final servizi = await _clientiRepository.getStoricoServizi(uid, clienteId);
      _storicoServizi = servizi;
      notifyListeners();
    } catch (e) {
      print("Errore nel ViewModel fetchStoricoServizi: $e");
    }
  }

}