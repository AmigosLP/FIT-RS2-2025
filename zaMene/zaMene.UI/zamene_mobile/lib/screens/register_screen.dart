import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _phoneController = TextEditingController(); // ⬅️ NEW

  String _gender = "Muško";
  bool _loading = false;
  bool _passwordVisible = false;

  String? _emailError;
  String? _usernameError;
  String? _nameError;

  final RegExp _nameAllowClass = RegExp(r"[A-Za-z\u00C0-\u017F \-]");
  final RegExp _nameRegex =
      RegExp(r"^[A-Za-z\u00C0-\u017F]+(?:[ -][A-Za-z\u00C0-\u017F]+)*$");

  final RegExp _phoneAllowClass = RegExp(r"[0-9+\-\s()]");

  String? _validateFirstName(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return "Unesite ime";
    if (!_nameRegex.hasMatch(v)) {
      return "Dozvoljena su samo slova, razmak i '-'.";
    }
    return null;
  }

  String? _validateLastName(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return "Unesite prezime";
    if (!_nameRegex.hasMatch(v)) {
      return "Dozvoljena su samo slova, razmak i '-'.";
    }
    return null;
  }

  bool _isValidEmail(String value) {
    final v = value.trim();
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
    return re.hasMatch(v);
  }

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  String? _validatePhone(String? value) {
    final v = (value ?? '').trim();

    if (v.isEmpty) return "Unesite broj telefona";

    if (v.contains('+') && !v.startsWith('+')) {
      return "Znak '+' može biti samo na početku broja.";
    }
    if (RegExp(r'\+').allMatches(v).length > 1) {
      return "Znak '+' smije biti naveden samo jednom.";
    }

    final digits = _digitsOnly(v);
    if (digits.length < 8 || digits.length > 15) {
      return "Unesite ispravan broj (8–15 cifara).";
    }

    return null;
  }

  Future<void> register() async {
    setState(() {
      _emailError = null;
      _usernameError = null;
      _nameError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final newUser = UserRegisterModel(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _userNameController.text.trim(),
      email: _emailController.text.trim(),
      gender: _gender,
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
    );

    setState(() => _loading = true);

    try {
      await UserService().register(newUser);

      if (!mounted) return;
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
      final error = e.toString().replaceFirst("Exception: ", "");
      setState(() {
        final low = error.toLowerCase();
        if (low.contains("email")) {
          _emailError = error;
        } else if (low.contains("korisničkim imenom") ||
            low.contains("korisničko ime") ||
            low.contains("username")) {
          _usernameError = error;
        } else if (low.contains("ime i prezime")) {
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
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: "Ime",
                      prefixIcon: Icon(Icons.person),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(_nameAllowClass),
                      LengthLimitingTextInputFormatter(50),
                    ],
                    validator: _validateFirstName,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: "Prezime",
                      prefixIcon: const Icon(Icons.person_outline),
                      errorText: _nameError,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(_nameAllowClass),
                      LengthLimitingTextInputFormatter(50),
                    ],
                    validator: _validateLastName,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _userNameController,
                    decoration: InputDecoration(
                      labelText: "Korisničko ime",
                      prefixIcon: const Icon(Icons.account_circle),
                      errorText: _usernameError,
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
                    ],
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? "Unesite korisničko ime"
                            : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      errorText: _emailError,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final v = (value ?? '').trim();
                      if (v.isEmpty) return "Unesite email";
                      if (!_isValidEmail(v)) {
                        return "Unesite ispravan email (npr. ime@domena.com).";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: "Telefon",
                      prefixIcon: Icon(Icons.phone),
                      hintText: "+387 62 123 456",
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(_phoneAllowClass),
                      LengthLimitingTextInputFormatter(20),
                    ],
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: "Lozinka",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => _passwordVisible = !_passwordVisible),
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
                          onChanged: (value) => setState(() => _gender = value!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Žensko"),
                          value: "Žensko",
                          groupValue: _gender,
                          onChanged: (value) => setState(() => _gender = value!),
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
                            child: const Text("Registruj se", style: TextStyle(fontSize: 16)),
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
