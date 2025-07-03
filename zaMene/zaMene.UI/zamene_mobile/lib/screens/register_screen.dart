import 'package:flutter/material.dart';
import 'package:zamene_mobile/models/user_register_model.dart';
import 'package:zamene_mobile/services/user_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _gender = "Muško";
  bool _loading = false;
  bool _passwordVisible = false; // 👈 Dodano

  String? _emailError;
  String? _usernameError;
  String? _nameError;
  String? _emailFormatError;

  Future<void> register() async {
    setState(() {
      _emailError = null;
      _usernameError = null;
      _nameError = null;
      _emailFormatError = null;
    });

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_emailController.text.trim())) {
      setState(() {
        _emailFormatError = "Email nije u ispravnom formatu.";
      });
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final newUser = UserRegisterModel(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _userNameController.text.trim(),
      email: _emailController.text.trim(),
      gender: _gender,
      password: _passwordController.text,
    );

    setState(() {
      _loading = true;
    });

    try {
      await UserService().register(newUser);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Uspješno"),
          content: const Text("Registracija uspješna. Prijavite se."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      String error = e.toString().replaceFirst("Exception: ", "");

      setState(() {
        if (error.contains("email")) {
          _emailError = error;
        } else if (error.contains("korisničkim imenom")) {
          _usernameError = error;
        } else if (error.contains("ime i prezime")) {
          _nameError = error;
        } else {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Greška"),
              content: Text(error),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registracija")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: "Ime",
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => value!.isEmpty ? "Unesite ime" : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: "Prezime",
                      prefixIcon: const Icon(Icons.person_outline),
                      errorText: _nameError,
                    ),
                    validator: (value) => value!.isEmpty ? "Unesite prezime" : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _userNameController,
                    decoration: InputDecoration(
                      labelText: "Korisničko ime",
                      prefixIcon: const Icon(Icons.account_circle),
                      errorText: _usernameError,
                    ),
                    validator: (value) => value!.isEmpty ? "Unesite korisničko ime" : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      errorText: _emailError ?? _emailFormatError,
                    ),
                    validator: (value) => value!.isEmpty ? "Unesite email" : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible, // 👈 Dodano
                    decoration: InputDecoration(
                      labelText: "Lozinka",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton( // 👈 Dodano
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Unesite lozinku";
                      }
                      if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$')
                          .hasMatch(value)) {
                        return "Lozinka mora imati:\n- Min 8 karaktera\n- Veliko i malo slovo\n- Broj\n- Specijalni znak";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Spol",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Muško"),
                          value: "Muško",
                          groupValue: _gender,
                          onChanged: (value) {
                            setState(() {
                              _gender = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Žensko"),
                          value: "Žensko",
                          groupValue: _gender,
                          onChanged: (value) {
                            setState(() {
                              _gender = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _loading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: 250,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: register,
                            child: const Text(
                              "Registruj se",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
