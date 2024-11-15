import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

List<List<DateTime?>> calendario(int year, int month) {
  // Righe e colonne del calendario
  const int rows = 6;
  const int columns = 7;

  // Otteniamo il primo giorno del mese
  final DateTime firstDayOfMonth = DateTime(year, month, 1);

  // Otteniamo l'ultimo giorno del mese
  final DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

  // Giorno della settimana del primo giorno del mese (Lunedì = 1, Domenica = 7)
  int startDayOfWeek = (firstDayOfMonth.weekday + 6) % 7;

  // Otteniamo il numero di giorni nel mese
  final int daysInMonth = lastDayOfMonth.day;

  // Creiamo una lista per rappresentare il calendario del mese
  List<List<DateTime?>> monthArray =
  List.generate(rows, (_) => List.filled(columns, null));

  int currentRow = 0;
  int currentCol = startDayOfWeek;

  // Riempio i giorni del mese corrente
  for (int day = 1; day <= daysInMonth; day++) {
    monthArray[currentRow][currentCol] = DateTime(year, month, day);
    currentCol++;
    if (currentCol == 7) {
      currentCol = 0;
      currentRow++;
    }
  }

  // Riempio i giorni vuoti del mese precedente
  DateTime previousMonthDay =
  firstDayOfMonth.subtract(Duration(days: startDayOfWeek));
  for (int col = 0; col < startDayOfWeek; col++) {
    monthArray[0][col] = previousMonthDay;
    previousMonthDay = previousMonthDay.add(Duration(days: 1));
  }

  // Riempio i giorni vuoti del mese successivo
  DateTime nextMonthDay = lastDayOfMonth.add(Duration(days: 1));
  for (int row = currentRow; row < rows; row++) {
    for (int col = currentCol; col < columns; col++) {
      if (monthArray[row][col] == null) {
        monthArray[row][col] = nextMonthDay;
        nextMonthDay = nextMonthDay.add(Duration(days: 1));
      }
    }
    currentCol = 0;
  }

  return monthArray;
}