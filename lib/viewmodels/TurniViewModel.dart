import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../models/Turni.dart';
import '../repositories/TurniRepository.dart';

class TurniViewModel extends ChangeNotifier {
  final TurniRepository _turniRepository = TurniRepository();
  List<TurnoModel> _turni = [];

  List<TurnoModel> get turni => _turni;

  Future<void> loadTurni(String uid) async {
    _turni = await _turniRepository.getTurni(uid);
    notifyListeners();
  }
}