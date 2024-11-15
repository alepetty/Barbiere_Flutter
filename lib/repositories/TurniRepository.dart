
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Turni.dart';

class TurniRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TurnoModel>> getTurni(String uid) async {
    try {
      final turniSnapshot = await _firestore
          .collection("users")
          .doc(uid)
          .collection("Turni")
          .get();

      List<TurnoModel> turni = turniSnapshot.docs.map((doc) {
        return TurnoModel(
          id: doc.id,
          start: doc['start'] ?? '',
          end: doc['end'] ?? '',
        );
      }).toList();

      return turni;
    } catch (e) {
      print("Errore nel caricamento dei turni: $e");
      return [];
    }
  }

}

