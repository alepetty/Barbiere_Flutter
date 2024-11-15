import 'package:barberflutter/models/Cliente.dart';
import 'package:barberflutter/models/Prenotazione/Servizio.dart';
import 'package:barberflutter/models/Turni.dart';
import 'Prenoatzione.dart';

class PrenotazioneCompleta {
  PrenotazioneModel prenotazione;
  ClienteModel cliente;
  TurnoModel turno;



  PrenotazioneCompleta({
    required this.prenotazione,
    required this.cliente ,
    required this.turno ,

  });
}


