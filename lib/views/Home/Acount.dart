import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/UserViewModel.dart';

class AccountPage extends StatelessWidget {
  final String uid;
  AccountPage({required this.uid});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserViewModel()..fetchUserData(uid),
      child: Scaffold(
        appBar: AppBar(title: Text("User Profile")),
        body: Consumer<UserViewModel>(
          builder: (context, userViewModel, child) {
            if (userViewModel.user == null) {
              return Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                Text("Name: ${userViewModel.user!.name}"),
                Text("Surname: ${userViewModel.user!.surname}"),
                Text("Sex: ${userViewModel.user!.sex}"),
                Text("Date of Birth: ${userViewModel.user!.dateOfBirth}"),
                Text("Activity Name: ${userViewModel.user!.nameActivity}"),
                Text("Telephone: ${userViewModel.user!.telephoneActivity}"),
                Text("Address: ${userViewModel.user!.via}"),
                Text("Schedule: ${userViewModel.user!.orario}"),
                Text("Last Updated: ${userViewModel.user!.lastUpdated}"),
                Text("Storico Aggiornato: ${userViewModel.user!.storicoAggiornato ? 'Yes' : 'No'}"),
              ],
            );
          },
        ),
      ),
    );
  }
}