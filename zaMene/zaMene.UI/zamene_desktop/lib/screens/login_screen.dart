import 'package:flutter/material.dart';
import 'package:zamene_desktop/layouts/master_screen.dart';
import 'package:zamene_desktop/models/login_model.dart';
import 'package:zamene_desktop/providers/user_provider.dart';
import 'package:zamene_desktop/screens/nekretnine_screen.dart';

// Definicija custom exceptiona, ako nemaš već u nekom drugom fajlu:
class NotAdminException implements Exception {
  final String message;
  NotAdminException(this.message);
  @override
  String toString() => message;
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Image.asset("assets/images/logo.png", height: 100, width: 100),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      String username = _usernameController.text.trim();
                      String password = _passwordController.text;

                      try {
                        UserProvider provider = UserProvider();
                        LoginModel model = LoginModel(username: username, password: password);

                        await provider.userLogin(model);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Login uspješan'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MasterScreen(
                              "Nekretnine",
                              NekretnineScreen(),
                            ),
                          ),
                        );
                      } on NotAdminException catch (e) {
                        // Specifična poruka za korisnike koji nisu admin
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      } catch (e) {
                        // Ostale greške (pogrešan username/password i sl.)
                        String errorMessage = e.toString();
                        if (errorMessage.startsWith("Exception:")) {
                          errorMessage = errorMessage.replaceFirst("Exception:", "").trim();
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text("Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
