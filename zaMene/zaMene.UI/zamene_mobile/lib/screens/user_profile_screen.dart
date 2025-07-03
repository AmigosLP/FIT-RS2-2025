import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zamene_mobile/services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _imeController = TextEditingController();
  final TextEditingController _prezimeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  File? novaSlika;

  String? trenutniUsername;
  String? trenutniIme;
  String? trenutniPrezime;
  String? trenutnaSlikaUrl;

  final UserService userService = UserService();

  Future<void> _ucitajProfil() async {
    try {
      final profil = await userService.getUserProfile();

      setState(() {
        _imeController.text = profil['firstName'] ?? '';
        _prezimeController.text = profil['lastName'] ?? '';
        _usernameController.text = profil['username'] ?? '';
        trenutniIme = profil['firstName'];
        trenutniPrezime = profil['lastName'];
        trenutniUsername = profil['username'];
        trenutnaSlikaUrl = profil['profileImageUrl'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri učitavanju profila: $e")),
      );
    }
  }

  Future<void> odaberiNovuSliku() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        novaSlika = File(picked.path);
      });
    }
  }

  Future<void> spremiPromjene() async {
    try {
      final userId = await userService.getUserIdFromToken();

      final String? novoIme =
          _imeController.text != trenutniIme ? _imeController.text : null;
      final String? novoPrezime =
          _prezimeController.text != trenutniPrezime ? _prezimeController.text : null;
      final String? noviUsername =
          _usernameController.text != trenutniUsername ? _usernameController.text : null;

      if (novoIme == null &&
          novoPrezime == null &&
          noviUsername == null &&
          novaSlika == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nema promjena za spremiti.")),
        );
        return;
      }

      await userService.updateProfile(
        firstName: novoIme ?? '',
        lastName: novoPrezime ?? '',
        username: noviUsername ?? '',
        profileImage: novaSlika,
        userId: userId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil uspješno ažuriran.")),
      );
      _ucitajProfil();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _ucitajProfil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Moj profil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: odaberiNovuSliku,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: novaSlika != null
                      ? FileImage(novaSlika!)
                      : (trenutnaSlikaUrl != null
                          ? NetworkImage(trenutnaSlikaUrl!)
                          : const AssetImage("assets/images/user.png"))
                          as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _imeController,
                decoration: const InputDecoration(labelText: 'Ime'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _prezimeController,
                decoration: const InputDecoration(labelText: 'Prezime'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Korisničko ime'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: spremiPromjene,
                child: const Text("Spremi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
