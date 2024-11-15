import 'package:barberflutter/ui/theme.dart';
import 'package:barberflutter/views/Clienti/Clienti.dart';
import 'package:flutter/material.dart';

import '../Agenda/Agenda.dart';
import '../Home/Home.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;

  CustomBottomBar({required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Evita di navigare se già su quella schermata

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Agenda()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ClientiPage()),
        );
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      backgroundColor: AppColors.blackNavigation,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Prenotazioni',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_rounded),
          label: 'Clienti',
        ),
      ],
    );
  }
}