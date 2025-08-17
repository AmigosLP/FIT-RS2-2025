import 'package:flutter/material.dart';
import 'package:zamene_desktop/layouts/master_screen.dart';
import 'package:zamene_desktop/models/login_model.dart';
import 'package:zamene_desktop/providers/user_provider.dart';

class NotAdminException implements Exception {
  final String message;
  NotAdminException(this.message);
  @override
  String toString() => message;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

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
                  Image.asset("assets/images/zamenelogo.png", height: 80, width: 80),
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
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
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
                            builder: (context) => const MasterScreen(),
                          ),
                        );
                      } on NotAdminException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      } catch (e) {
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
