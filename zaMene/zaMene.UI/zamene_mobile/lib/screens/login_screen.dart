import 'package:flutter/material.dart';
import 'package:zamene_mobile/providers/auth_provide.dart';
import 'package:zamene_mobile/services/user_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _passwordVisible = false;

  Future<void> login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Obavještenje"),
          content: Text("Unesite korisničko ime i lozinku."),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = await UserService().login(username, password);

      AuthProvider.username = user['username'];
      AuthProvider.password = password;
      AuthProvider.displayName = "${user['firstName']} ${user['lastName']}";

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      final raw = e.toString().replaceFirst('Exception: ', '').toLowerCase();

      String message;
      if (raw.contains('unauthorized') ||
          raw.contains('401') ||
          raw.contains('invalid') ||
          raw.contains('wrong') ||
          raw.contains('incorrect') ||
          raw.contains('not found') ||
          raw.contains('neisprav') ||
          raw.contains('pogreš') ||
          raw.contains('netačn')) {
        message = "Pogrešno korisničko ime ili lozinka.";
        _passwordController.clear();
      } else if (raw.contains('network') ||
          raw.contains('socket') ||
          raw.contains('timed out') ||
          raw.contains('timeout') ||
          raw.contains('connection')) {
        message =
            "Mrežna greška ili server trenutno nije dostupan. Pokušajte ponovo.";
      } else {
        message = "Došlo je do greške pri prijavi. Pokušajte ponovo.";
      }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Greška"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prijava")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/zaMeneLogo2.png",
                  height: 120,
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Korisničko ime",
                    prefixIcon: Icon(Icons.person),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: "Lozinka",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() {
                        _passwordVisible = !_passwordVisible;
                      }),
                    ),
                  ),
                  onSubmitted: (_) => login(),
                ),
                const SizedBox(height: 30),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: login,
                        child: const Text("Prijavi se"),
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: goToRegister,
                  child: const Text("Nemate račun? Registruj se"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
