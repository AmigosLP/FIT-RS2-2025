import 'package:flutter/material.dart';
import 'package:zamene_desktop/main.dart';
import 'package:zamene_desktop/providers/auth_provider.dart';
import 'package:zamene_desktop/screens/dashboard_screen.dart';
import 'package:zamene_desktop/screens/login_screen.dart';
import 'package:zamene_desktop/screens/nekretnine_screen.dart';
import 'package:zamene_desktop/screens/recenzije_screen.dart';
// import 'package:zamene_desktop/screens/properties_screen.dart'; // obavezno kreiraj ili dummy file

class MasterScreen extends StatefulWidget {
  MasterScreen(this.title, this.child, {super.key});
  String title;
  Widget child;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  String _userName = "";

  @override
  void initState() {
    super.initState();
    _userName = AuthProvider.displayName ?? "Nepoznato";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: _backButton(context),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Navigacijska dugmad
            _navButton("Nekretnine", NekretnineScreen()),
            _navButton("Recenzije", RecenzijeScreen()),
            _navButton("Dashboard", StatisticsScreen()),

            if (_userName.isNotEmpty)
              TextButton(
                onPressed: null, // Neaktivno dugme
                child: Text(
                  "Dobrodošli, $_userName",
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
      body: widget.child,
    );
  }

  Widget _navButton(String title, Widget screen) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Text(title, style: TextStyle(color: Colors.white)),
    );
  }

  Widget _backButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.home, color: Colors.white),
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      },
      tooltip: 'Povratak na login',
    );
  }
}
