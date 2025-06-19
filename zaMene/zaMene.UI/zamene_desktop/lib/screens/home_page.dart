import 'package:flutter/material.dart';
import 'package:zamene_desktop/providers/auth_provider.dart';
import 'package:zamene_desktop/screens/nekretnine_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (AuthProvider.roles.contains('Admin')) {
      return const NekretnineScreen(); // zamijeni sa AdminDashboard ako želiš
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text("Pristup odbijen")),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "Nemate pristup ovoj aplikaciji. Samo administratori mogu koristiti desktop aplikaciju.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }
}
