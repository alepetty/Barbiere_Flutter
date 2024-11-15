import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/AuthViewModel.dart';
import '../Navigation/BottomNavigationBar.dart';
import 'Acount.dart';


class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Home'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountPage(uid: FirebaseAuth.instance.currentUser!.uid)),
                  );
                },
                icon: Icon(Icons.account_circle_sharp))
          ],
      ),
      body: Center(
          child: Text('Home Screen')
      ),
      bottomNavigationBar: CustomBottomBar(currentIndex: 0),
    );
  }
}