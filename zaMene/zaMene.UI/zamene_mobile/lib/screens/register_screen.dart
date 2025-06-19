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

  // Backend error messages for specific fields
  String? _emailError;
  String? _usernameError;
  String? _nameError;
  String? _emailFormatError;

  Future<void> _register() async {
    setState(() {
      // Reset errors before new validation
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
        _emailError = null;
        _usernameError = null;
        _nameError = null;

        if (error.contains("email")) {
          _emailError = error;
        } else if (error.contains("korisničkim imenom")) {
          _usernameError = error;
        } else if (error.contains("ime i prezime")) {
          _nameError = error;
        } else {
          // fallback ako nije ni jedna od gore navedenih grešaka
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 30),

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
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Lozinka",
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) => value!.length < 4
                    ? "Lozinka mora imati bar 4 karaktera"
                    : null,
              ),
              const SizedBox(height: 30),

              Text(
                "Spol",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Row(
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
              const SizedBox(height: 10),

              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _register,
                      child: const Text("Registruj se"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
