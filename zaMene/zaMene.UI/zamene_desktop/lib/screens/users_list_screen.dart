import 'package:flutter/material.dart';
import 'package:zamene_desktop/layouts/master_screen.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MasterScreen("List of users", Column(
      children: [
        Text("Users list"),
        SizedBox(height: 8,),
        ElevatedButton(onPressed: () {
          Navigator.pop(context);
        }, child: Text("Back"))
      ],));
  }
}