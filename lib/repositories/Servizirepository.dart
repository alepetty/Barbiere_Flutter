import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Prenotazione/Servizio.dart';

class Servizirepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> getServizi(
      String uid,
      Function(List<ServizioModel>) onSuccess,

      ) async {
    try {
      final querySnapshot = await _firestore
          .collection("users")
          .doc(uid)
          .collection("Servizi")
          .get();

      List<ServizioModel> serviziList = querySnapshot.docs.map((doc) {
        return ServizioModel(
          id: doc['id'] ?? '',
          nome: doc['nome'] ?? '',
          prezzo: doc['prezzo'] ?? '',
        );
      }).toList();
      onSuccess(serviziList);
    } catch (e) {

    }

  }
  Future<String> getServiceName(String uid, String servizioId) async {
    final servizioDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("Servizi")
        .doc(servizioId)
        .get();

    if (servizioDoc.exists) {
      return servizioDoc.data()?['nome'] ?? 'Nome non disponibile';
    } else {
      return 'Nome non disponibile';
    }
  }

}

