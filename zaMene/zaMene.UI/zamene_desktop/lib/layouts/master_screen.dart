import 'package:flutter/material.dart';
import 'package:zamene_desktop/providers/auth_provider.dart';
import 'package:zamene_desktop/screens/dashboard_screen.dart';
import 'package:zamene_desktop/screens/login_screen.dart';
import 'package:zamene_desktop/screens/nekretnine_screen.dart';
import 'package:zamene_desktop/screens/recenzije_screen.dart';
import 'package:zamene_desktop/screens/support_ticket_screenn.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  String _userName = "";
  int _selectedIndex = 0;

  final List<({String title, Widget screen})> _tabs = const [
    (title: "Nekretnine", screen: NekretnineScreen()),
    (title: "Recenzije", screen: RecenzijeScreen()),
    (title: "Dashboard", screen: StatisticsScreen()),
    (title: "Support", screen: SupportScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _userName = AuthProvider.displayName ?? "Nepoznato";
  }

  void _onNavButtonTapped(int index) {
    if (index < 0 || index >= _tabs.length) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final current = _tabs[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: _backButton(context),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_tabs.length, (i) {
            final selected = _selectedIndex == i;
            return TextButton(
              onPressed: () => _onNavButtonTapped(i),
              child: Text(
                _tabs[i].title,
                style: TextStyle(
                  color: selected ? Colors.yellow : Colors.white,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }),
        ),
        centerTitle: true,
        actions: [
          if (_userName.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text("Dobrodošli, Admin", style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
      body: current.screen,
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
