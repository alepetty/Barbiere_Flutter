import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/User.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return UserModel(
          name: userDoc['name'] ?? '',
          surname: userDoc['surname'] ?? '',

        );
      }
      return null;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<void> controllaAggiornamentoStorico(String uid) async {
    final userRef = FirebaseFirestore.instance.collection("users").doc(uid);
    print("Inizio controllo aggiornamento storico per utente: $uid");

    try {
      // Recupera i dati dell'utente
      final userSnapshot = await userRef.get();
      if (!userSnapshot.exists) {
        print("Utente non trovato.");
        return;
      }

      bool storicoAggiornato = userSnapshot.data()?["storicoAggiornato"] ?? false;
      String lastUpdated = userSnapshot.data()?["lastUpdated"] ?? "";

      print("Valore iniziale di 'storicoAggiornato': $storicoAggiornato");
      print("Valore iniziale di 'lastUpdated': $lastUpdated");

      // Ottieni la data corrente
      final today =DateFormat('yyyy-MM-dd').format(DateTime.now());;
      print("Data corrente: $today");

      // Se la data corrente è diversa dall'ultima aggiornata
      if (today != lastUpdated) {
        print("La data di oggi è diversa dall'ultima aggiornata. Avvio aggiornamento storico.");

        // Esegui l'aggiornamento dello storico prenotazioni
        await aggiornaStoricoPrenotazioni(DateTime.now(), uid);

        // Imposta 'storicoAggiornato' su true e aggiorna 'lastUpdated'
        await userRef.update({
          "storicoAggiornato": true,
          "lastUpdated": today,
        });

        print("Aggiornamento dello storico completato. 'storicoAggiornato' impostato su true.");
      } else {
        print("Storico già aggiornato per la data odierna.");
      }
    } catch (e) {
      print("Errore nel recuperare i dati utente o nell'aggiornare i campi: $e");
    }
  }





}

Future<void> aggiornaStoricoPrenotazioni(DateTime date, String uid) async {
  final giorniRef = FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("Day");

  try {
    print("Comincio aggiornaStoricoPrenotazioni");
    // Ottiene i documenti dei giorni
    final giorniSnapshot = await giorniRef.get();
    for (var giornoDoc in giorniSnapshot.docs) {
      // Ottieni la data dal documento come stringa
      final dataGiorno = giornoDoc.get("data");

      // Se "data" non è una stringa, salta questo documento
      if (dataGiorno is! String) continue;

      final dataGiornoParsed = DateTime.parse(dataGiorno);

      // Verifica se la data è antecedente alla data passata e non è il giorno corrente
      if (dataGiornoParsed.isBefore(date) && !_isSameDay(dataGiornoParsed, date)) {
        final prenotazioniRef = giornoDoc.reference.collection("Prenotazioni");
        final prenotazioniSnapshot = await prenotazioniRef.get();

        for (var prenotazioneDoc in prenotazioniSnapshot.docs) {
          final clienteId = prenotazioneDoc.get("clienteId");
          final servizioId = prenotazioneDoc.get("servizioId");
          if (clienteId == null || servizioId == null) continue;

          // Aggiorna lo storico del cliente
          await aggiornaStoricoCliente(uid, clienteId, servizioId,prenotazioneDoc.get("id"));

          // Elimina la prenotazione
          await prenotazioneDoc.reference.delete();
        }

        // Elimina anche il documento del giorno se tutte le prenotazioni sono state rimosse
        await giornoDoc.reference.delete();
      }
    }
  } catch (e) {
    print("Errore nell'aggiornare lo storico delle prenotazioni: $e");
  }
}

// Funzione per verificare se due date rappresentano lo stesso giorno
bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

Future<void> aggiornaStoricoCliente(
    String uid, String clienteId, String servizioId, String prenotazioneId) async {
  final clienteRef = FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("Clienti")
      .doc(clienteId);
  final storicoRef = clienteRef.collection("storico");

  try {
    // Aggiorna il numero di prenotazioni
    final prenotazioniRef = storicoRef.doc("prenotazioni");
    final prenotazioniDoc = await prenotazioniRef.get();

    // Se il documento esiste, recupera il numero di prenotazioni, altrimenti inizializza a 0
    final numeroPrenotazioni = (prenotazioniDoc.data()?["numeroPrenotazioni"] ?? 0) as int;
    await prenotazioniRef.set({"numeroPrenotazioni": numeroPrenotazioni + 1});

    // Aggiorna il numero di volte che il servizio è stato fatto
    final serviziRef = storicoRef.doc("servizi");
    final serviziDoc = await serviziRef.get();

    // Se il documento esiste, recupera la mappa dei servizi, altrimenti inizializza una mappa vuota
    final Map<String, dynamic> serviziMap = serviziDoc.data() != null
        ? Map<String, dynamic>.from(serviziDoc.data()!)
        : {};

    // Aggiorna il conteggio per il servizio specifico
    final numeroVolte = (serviziMap[servizioId] ?? 0) as int;
    serviziMap[servizioId] = numeroVolte + 1;

    await serviziRef.set(serviziMap);

    // Recupera le prenotazioni esistenti per confrontare e rimuovere quella con l'ID specificato
    final clienteSnapshot = await clienteRef.get();
    final List<dynamic> prenotazioni = clienteSnapshot.data()?["prenotazioni"] ?? [];

    // Trova l'oggetto da rimuovere
    final prenotazioneDaRimuovere = prenotazioni.firstWhere(
          (prenotazione) => prenotazione["id"] == prenotazioneId,
      orElse: () => null,
    );

    if (prenotazioneDaRimuovere != null) {
      // Rimuovi l'oggetto dall'array
      await clienteRef.update({
        "prenotazioni": FieldValue.arrayRemove([prenotazioneDaRimuovere]),
      });
      print("Prenotazione con ID $prenotazioneId rimossa correttamente.");
    } else {
      print("Nessuna prenotazione trovata con ID $prenotazioneId.");
    }
  } catch (e) {
    print("Errore durante l'aggiornamento dello storico cliente: $e");
  }
}



