import 'package:flutter/material.dart';
import 'package:zamene_desktop/providers/auth_provider.dart';
import 'package:zamene_desktop/screens/dashboard_screen.dart';
import 'package:zamene_desktop/screens/login_screen.dart';
import 'package:zamene_desktop/screens/nekretnine_screen.dart';
import 'package:zamene_desktop/screens/recenzije_screen.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({Key? key}) : super(key: key);

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  String _userName = "";
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const NekretnineScreen(),
    const RecenzijeScreen(),
    const StatisticsScreen(),
  ];

  final List<String> _titles = [
    "Nekretnine",
    "Recenzije",
    "Dashboard",
  ];

  @override
  void initState() {
    super.initState();
    _userName = AuthProvider.displayName ?? "Nepoznato";
  }

  void _onNavButtonTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            _navButton("Nekretnine", 0),
            _navButton("Recenzije", 1),
            _navButton("Dashboard", 2),
          ],
        ),
        centerTitle: true,
        actions: [
          if (_userName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  "Dobrodošli Admin",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _screens[_selectedIndex],
    );
  }

  Widget _navButton(String title, int index) {
    final bool selected = _selectedIndex == index;
    return TextButton(
      onPressed: () => _onNavButtonTapped(index),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.yellow : Colors.white,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.white),
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      },
      tooltip: 'Odjava',
    );
  }
}
