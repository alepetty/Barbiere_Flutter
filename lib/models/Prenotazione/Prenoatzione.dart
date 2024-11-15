import 'package:intl/intl.dart';

class PrenotazioneModel {
  String id;
  String clienteId;
  String servizioId;
  String data;
  String turno;

  PrenotazioneModel({
    this.id = "",
    this.clienteId = "",
    this.servizioId = "",
    this.data = "",
    this.turno = "",
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteId': clienteId,
      'servizioId': servizioId,
      'data': data,
      'turno':turno
    };
  }
}


