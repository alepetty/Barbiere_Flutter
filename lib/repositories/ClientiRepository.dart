import 'package:barberflutter/models/Cliente.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';



class ClientiRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> getClienti(String uid,
      Function(List<ClienteModel>) onSuccess,) async {
    try {
      final querySnapshot = await _firestore
          .collection("users")
          .doc(uid)
          .collection("Clienti")
          .get();

      List<ClienteModel> clientiList = querySnapshot.docs.map((doc) {
        print(doc['id']);
        return ClienteModel(
          id: doc.data().containsKey('id') ? doc['id'] : '',
          nome: doc.data().containsKey('nome') ? doc['nome'] : '',
          cognome: doc.data().containsKey('cognome') ? doc['cognome'] : '',
          telefono: doc.data().containsKey('telefono') ? doc['telefono'] : '',
        );
      }).toList();

      onSuccess(clientiList); // Chiama il callback con la lista
    } catch (e) {
      print("Errore nel caricamento dei clienti: $e");
    }
  }


  Future<void> createClient({
    required String uid,
    required String nome,
    required String cognome,
    required String telefono,
    required VoidCallback onSuccess,
  }) async {
    // Genera un ID cliente univoco
    final uuid = Uuid();
    final idCliente = uuid.v4();
    final cliente = {
      'id': idCliente,
      'nome': nome,
      'cognome': cognome,
      'telefono': telefono,
    };

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('Clienti')
          .doc(idCliente)
          .set(cliente);
      onSuccess(); // Esegui effettivamente il callback qui
    } catch (e) {
      print("Errore durante la creazione del cliente: $e");
    }
  }


  Future<void> updateClient({
    required String uid,
    required String clientId,
    required String nome,
    required String cognome,
    required String telefono,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('Clienti')
          .doc(clientId)
          .update({
        'nome': nome,
        'cognome': cognome,
        'telefono': telefono,
      });
    } catch (e) {
      print("Errore durante l'aggiornamento del cliente: $e");
    }
  }

  // Funzione per eliminare un cliente
  Future<void> deleteClient({
    required String uid,
    required String clientId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('Clienti')
          .doc(clientId)
          .delete();
    } catch (e) {
      print("Errore durante l'eliminazione del cliente: $e");
    }
  }


  Future<int?> getNumeroPrenotazioni(String uid, String clienteId) async {
    try {
      final document = await _firestore
          .collection('users')
          .doc(uid)
          .collection('Clienti')
          .doc(clienteId)
          .collection('storico')
          .doc('prenotazioni')
          .get();

      if (document.exists) {
        return document.data()?['numeroPrenotazioni'] as int?;
      } else {
        throw Exception("Documento 'prenotazioni' non trovato.");
      }
    } catch (e) {
      print("Errore durante il recupero delle prenotazioni: $e");
      return null;
    }
  }



  Future<List<Map<String, dynamic>>> getStoricoServizi(String uid, String clienteId) async {
    try {
      // Ottieni lo storico dei servizi dal documento
      final storicoDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('Clienti')
          .doc(clienteId)
          .collection('storico')
          .doc('servizi')
          .get();

      if (storicoDoc.exists) {
        final storicoData = storicoDoc.data();

        if (storicoData == null || storicoData.isEmpty) {
          return [];
        }

        // Itera sugli ID dei servizi e recupera i dettagli
        List<Map<String, dynamic>> serviziStorico = [];
        for (var entry in storicoData.entries) {
          String servizioId = entry.key;
          int volte = entry.value as int;

          // Ottieni i dettagli del servizio
          final servizioDoc = await _firestore
              .collection('users')
              .doc(uid)
              .collection('Servizi')
              .doc(servizioId)
              .get();

          if (servizioDoc.exists) {
            final servizioData = servizioDoc.data();
            if (servizioData != null) {
              serviziStorico.add({
                'id': servizioId,
                'nome': servizioData['nome'],
                'prezzo': servizioData['prezzo'],
                'volte': volte,
              });
            }
          }
        }
        return serviziStorico;
      } else {
        print("Documento 'servizi' non trovato.");
        return [];
      }
    } catch (e) {
      print("Errore durante il recupero dello storico dei servizi: $e");
      return [];
    }
  }


}