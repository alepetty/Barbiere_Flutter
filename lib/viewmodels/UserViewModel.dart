import 'package:barberflutter/models/User.dart';
import 'package:barberflutter/repositories/UserRepository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  UserModel? user;

  Future<void> fetchUserData(String uid) async {
    user = await _userRepository.fetchUserData(uid);
    notifyListeners();
  }
}