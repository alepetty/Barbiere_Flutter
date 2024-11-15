import 'package:intl/intl.dart';

class UserModel {
  String name;
  String surname;
  String sex;
  String dateOfBirth;
  String nameActivity;
  String telephoneActivity;
  String via;
  String orario;
  bool storicoAggiornato;
  String lastUpdated;

  UserModel({
    this.name = "",
    this.surname = "",
    this.sex = "",
    this.dateOfBirth = "",
    this.nameActivity = "",
    this.telephoneActivity = "",
    this.via = "",
    this.orario = "",
    this.storicoAggiornato = false,
    String? lastUpdated,
  }) : lastUpdated = lastUpdated ?? _getCurrentDate();

  // Metodo statico per ottenere la data corrente
  static String _getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }
}