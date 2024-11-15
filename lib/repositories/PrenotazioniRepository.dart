import 'package:barberflutter/models/Cliente.dart';
import 'package:barberflutter/models/Day.dart';
import 'package:barberflutter/models/Prenotazione/Prenoatzione.dart';
import 'package:barberflutter/models/Turni.dart';
import 'package:barberflutter/repositories/TurniRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';


import '../models/Prenotazione/Prenotazione_completa.dart';
import '../models/User.dart';

class Prenotazionirepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TurniRepository _turniRepository = TurniRepository();

  Future<DayModel?> getDayData(String uid, DateTime data) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(data);
    try {
      print(uid);
      print(formattedDate);
      DocumentSnapshot dayDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('Day')
          .doc(formattedDate)
          .get();

      if (dayDoc.exists) {
        print(dayDoc['full']);
        return DayModel(
          data: dayDoc['data'] ?? '',
          full: dayDoc['full'] ??
              false, // Assumendo che 'full' sia di tipo bool
        );
      } else {
        createDayInCalendar(data, uid);
      };
    } catch (e) {
      print("Error getdata $formattedDate : $e");
      return null;
    }
  }

  Future<void> createDayInCalendar(DateTime date, String uid) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final dayData = DayModel(data: formattedDate,
        full: false); // Usa toIso8601String() per il formato della data
    final dayRef = _firestore.collection("users").doc(uid)
        .collection("Day")
        .doc(dayData.data);

    try {
      await dayRef.set(dayData.toMap());
      print("Giorno ${dayData.data} creato con successo.");
    } catch (e) {
      print("Errore nella creazione del giorno: $e");
    }
  }


  Future<void> getPrenotazioniConDettagli(String uid,
      DateTime date,
      Function(List<PrenotazioneCompleta>) onComplete) async {
    List<PrenotazioneCompleta> prenotazioni = [];

    try {
      // Step 1: Recupera le prenotazioni per la data specifica
      final result = await _firestore
          .collection("users")
          .doc(uid)
          .collection("Day")
          .doc(date.toIso8601String().split(
          "T")[0]) // Formatta la data come yyyy-MM-dd
          .collection("Prenotazioni")
          .get();

      if (result.docs.isEmpty) {
        onComplete([]);
        return;
      }

      int retrievedItems = 0; // Traccia quanti elementi sono stati processati

      for (var document in result.docs) {
        PrenotazioneModel? prenotazione = PrenotazioneModel(
          id: document['id'] ?? '',
          clienteId: document['clienteId'] ?? '',
          servizioId: document['servizioId'] ?? '',
          data: document['data'] ?? '',
          turno: document['turno'] ?? '',
        );

        if (prenotazione == null) {
          debugPrint("Prenotazione null per documento: ${document.id}");
          retrievedItems++;
          if (retrievedItems == result.docs.length) {
            onComplete(prenotazioni);
          }
          continue;
        }

        try {
          final clienteSnapshot = await _firestore
              .collection("users")
              .doc(uid)
              .collection("Clienti")
              .doc(prenotazione.clienteId)
              .get();

          final turnoSnapshot = await _firestore
              .collection("users")
              .doc(uid)
              .collection("Turni")
              .doc(prenotazione.turno)
              .get();

          ClienteModel? cliente = clienteSnapshot.exists
              ? ClienteModel(
            id: clienteSnapshot['id'] ?? '',
            nome: clienteSnapshot['nome'] ?? '',
            cognome: clienteSnapshot['cognome'] ?? '',
            telefono: clienteSnapshot['telefono'] ?? '',
          )
              : null;

          TurnoModel? turno = turnoSnapshot.exists
              ? TurnoModel(
            id: turnoSnapshot['id'] ?? '',
            start: turnoSnapshot['start'] ?? '',
            end: turnoSnapshot['end'] ?? '',

          )
              : null;

          if (cliente == null) {
            debugPrint(
                "Cliente non trovato per clienteId: ${prenotazione.clienteId}");
            retrievedItems++;
            if (retrievedItems == result.docs.length) {
              onComplete(prenotazioni);
            }
            continue;
          }

          if (turno == null) {
            debugPrint("Turno non trovato per turnoId: ${prenotazione.turno}");
            retrievedItems++;
            if (retrievedItems == result.docs.length) {
              onComplete(prenotazioni);
            }
            continue;
          }

          final prenotazioneCompleta = PrenotazioneCompleta(
            prenotazione: prenotazione,
            cliente: cliente,
            turno: turno,
          );

          prenotazioni.add(prenotazioneCompleta);
          retrievedItems++;

          if (retrievedItems == result.docs.length) {
            onComplete(prenotazioni);
          }
        } catch (e) {
          debugPrint("Errore nel recupero di cliente o turno: $e");
          retrievedItems++;
          if (retrievedItems == result.docs.length) {
            onComplete(prenotazioni);
          }
        }
      }
    } catch (e) {
      // Gestisci l'errore e restituisci una lista vuota
      debugPrint("Errore nel recupero delle prenotazioni: $e");
      onComplete([]);
    }
  }
  Future<void> deletePrenotazione(
     String uid,
     DateTime date,
     PrenotazioneCompleta prenotazione,
      Function onUpdate
  ) async {
    final dateString = date.toIso8601String().split("T")[0];
    DocumentReference clienteDocumentRef = _firestore
        .collection("users")
        .doc(uid)
        .collection("Clienti")
        .doc(prenotazione.cliente.id);
    // Esegui l'eliminazione della prenotazione dalla collezione Firestore
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("Day")
        .doc(dateString)
        .collection("Prenotazioni")
        .doc(prenotazione.prenotazione.id)
        .delete();

    await clienteDocumentRef.update({
      "prenotazioni": FieldValue.arrayRemove([prenotazione.prenotazione.toMap()])
    });
    await updateDayStatus(uid, dateString,onUpdate);

  }


  Future<void> createPrenotazione({
    required String uid,
    required PrenotazioneModel prenotazione,
    required Function onSuccess,
    required Function onUpdate,
  }) async {
    try {
      DocumentReference dayDocumentRef = _firestore
          .collection("users")
          .doc(uid)
          .collection("Day")
          .doc(prenotazione.data);

      DocumentReference clienteDocumentRef = _firestore
          .collection("users")
          .doc(uid)
          .collection("Clienti")
          .doc(prenotazione.clienteId);

      await dayDocumentRef
          .collection("Prenotazioni")
          .doc(prenotazione.id)
          .set(prenotazione.toMap());

      await clienteDocumentRef.update({
        "prenotazioni": FieldValue.arrayUnion([prenotazione.toMap()])
      });
      await updateDayStatus(uid, prenotazione.data,onUpdate);
      onSuccess();

    } catch (e) {
      print("Errore durante la creazione della prenotazione: $e");
    }
  }

  Future<void> updateDayStatus(String uid, String date, Function onUpdate) async {
    try {
      // Ottieni tutti i turni disponibili
      final turni = await _turniRepository.getTurni(uid);

      // Riferimento al documento del giorno specifico
      final dayDocumentRef = _firestore
          .collection("users")
          .doc(uid)
          .collection("Day")
          .doc(date);

      // Recupera il valore corrente di `full`
      final daySnapshot = await dayDocumentRef.get();
      bool currentFullStatus = daySnapshot.data()?['full'] ?? false;

      // Recupera le prenotazioni per il giorno specifico
      final prenotazioniSnapshot = await dayDocumentRef.collection("Prenotazioni").get();
      final turniPrenotati = prenotazioniSnapshot.docs
          .map((doc) => doc['turno'] as String)
          .toList();

      // Verifica se tutti i turni sono prenotati
      final allTurniBooked = turni.every((turno) => turniPrenotati.contains(turno.id));

      // Aggiorna lo stato solo se c'è una variazione
      if (currentFullStatus != allTurniBooked) {
        await dayDocumentRef.update({"full": allTurniBooked});

        // Chiama `onUpdate` solo se c'è stato un cambiamento
        onUpdate();
      }
    } catch (e) {
      print("Errore durante il recupero dei dati o aggiornamento dello stato: $e");
    }
  }



}
