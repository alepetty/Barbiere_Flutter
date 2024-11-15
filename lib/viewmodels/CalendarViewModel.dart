import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../function/Calendar.dart';

class CalendarViewModel extends ChangeNotifier {
  List<DateTime?> calendar = [];

  Future<void> updateCalendar(int year, int month) async {
    // Logica per generare il calendario
    List<List<DateTime?>> newCalendar = calendario(year, month);
    List<DateTime?> flatCalendar = newCalendar.expand((row) => row).toList();
    calendar = flatCalendar;
    notifyListeners();
  }


}