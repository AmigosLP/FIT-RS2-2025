import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zamene_mobile/models/support_ticket_model.dart';
import 'package:zamene_mobile/services/support_ticket_service.dart';
import 'package:zamene_mobile/services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  // CONTROLLERS – Profil
  final TextEditingController _imeController = TextEditingController();
  final TextEditingController _prezimeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // CONTROLLERS – Lozinka
  final TextEditingController _trenutnaLozinkaController = TextEditingController();
  final TextEditingController _novaLozinkaController = TextEditingController();
  final TextEditingController _potvrdiLozinkuController = TextEditingController();

  // CONTROLLERS – Support
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Password visibility
  bool _isTrenutnaLozinkaVisible = false;
  bool _isNovaLozinkaVisible = false;
  bool _isPotvrdiLozinkuVisible = false;

  // Profil podaci (trenutni radi diff-update)
  String? _trenutniIme;
  String? _trenutniPrezime;
  String? _trenutniUsername;
  String? _trenutniEmail;
  String? _trenutnaSlikaUrl;
  File? _novaSlika;

  String? _novaLozinkaError;
  bool _loadingProfil = true;
  bool _savingProfil = false;
  bool _savingPassword = false;
  bool _submittingTicket = false;

  // Support tickets
  late Future<List<SupportTicketModel>> _ticketsFuture;
  final _userService = UserService();
  final _ticketService = SupportTicketService();

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _ucitajProfil();
    _ticketsFuture = _ticketService.getMyTickets();
  }

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _trenutnaLozinkaController.dispose();
    _novaLozinkaController.dispose();
    _potvrdiLozinkuController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _ucitajProfil() async {
    try {
      final profil = await _userService.getUserProfile();
      setState(() {
        _imeController.text = profil['firstName'] ?? '';
        _prezimeController.text = profil['lastName'] ?? '';
        _usernameController.text = profil['username'] ?? '';
        _emailController.text = profil['email'] ?? '';

        _trenutniIme = profil['firstName'];
        _trenutniPrezime = profil['lastName'];
        _trenutniUsername = profil['username'];
        _trenutniEmail = profil['email'];
        _trenutnaSlikaUrl = profil['profileImageUrl'];
        _loadingProfil = false;
      });
    } catch (e) {
      setState(() => _loadingProfil = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri učitavanju profila: $e")),
      );
    }
  }

  Future<void> _odaberiNovuSliku() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _novaSlika = File(picked.path));
    }
  }

  Future<void> _spremiPromjeneProfila() async {
    FocusScope.of(context).unfocus();

    // Provjeri ima li ičega za spremiti
    final imaPromjena = _imeController.text != _trenutniIme ||
        _prezimeController.text != _trenutniPrezime ||
        _usernameController.text != _trenutniUsername ||
        _emailController.text != _trenutniEmail ||
        _novaSlika != null;

    if (!imaPromjena) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nema promjena za spremiti.")),
      );
      return;
    }

    setState(() => _savingProfil = true);
    try {
      final userId = await _userService.getUserIdFromToken();

      // šaljemo samo vrijednosti iz inputa (kao i ranije)
      await _userService.updateProfile(
        firstName: _imeController.text,
        lastName: _prezimeController.text,
        username: _usernameController.text,
        email: _emailController.text,
        password: '', // ne diramo lozinku ovdje
        profileImage: _novaSlika,
        userId: userId,
      );

      // osvježi "trenutne" vrijednosti da nove promjene pravilno diff-amo
      _trenutniIme = _imeController.text;
      _trenutniPrezime = _prezimeController.text;
      _trenutniUsername = _usernameController.text;
      _trenutniEmail = _emailController.text;
      _novaSlika = null;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil uspješno ažuriran."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška pri spremanju: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _savingProfil = false);
    }
  }

  Future<void> _promijeniLozinku() async {
    FocusScope.of(context).unfocus();

    if (_novaLozinkaController.text.isEmpty ||
        _potvrdiLozinkuController.text.isEmpty ||
        _trenutnaLozinkaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Molimo popunite sva polja za lozinku.")),
      );
      return;
    }

    if (_novaLozinkaController.text != _potvrdiLozinkuController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nova lozinka i potvrda se ne poklapaju.")),
      );
      return;
    }

    final nova = _novaLozinkaController.text;
    final lozinkaValidna = RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$')
        .hasMatch(nova);

    if (!lozinkaValidna) {
      setState(() {
        _novaLozinkaError =
            "Lozinka mora imati:\n- Min 8 karaktera\n- Veliko i malo slovo\n- Broj\n- Specijalni znak";
      });
      return;
    } else {
      setState(() => _novaLozinkaError = null);
    }

    setState(() => _savingPassword = true);
    try {
      await _userService.changePassword(
        currentPassword: _trenutnaLozinkaController.text,
        newPassword: _novaLozinkaController.text,
        confirmNewPassword: _potvrdiLozinkuController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lozinka uspješno promijenjena."),
          backgroundColor: Colors.green,
        ),
      );

      _trenutnaLozinkaController.clear();
      _novaLozinkaController.clear();
      _potvrdiLozinkuController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  Future<void> _posaljiTicket() async {
    FocusScope.of(context).unfocus();

    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unesite naslov i poruku tiketa.")),
      );
      return;
    }

    setState(() => _submittingTicket = true);
    try {
      await _ticketService.createTicket(subject: subject, message: message);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tiket poslan. Odgovori stižu u obavijestima."),
          backgroundColor: Colors.green,
        ),
      );

      _subjectController.clear();
      _messageController.clear();

      // osvježi listu tiketa ispod forme
      setState(() {
        _ticketsFuture = _ticketService.getMyTickets();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška pri slanju tiketa: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submittingTicket = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Moj profil"),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Profil', icon: Icon(Icons.person)),
              Tab(text: 'Lozinka', icon: Icon(Icons.lock)),
              Tab(text: 'Podrška', icon: Icon(Icons.support_agent)),
            ],
          ),
        ),
        body: _loadingProfil
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // ===================== 1) PROFIL =====================
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _odaberiNovuSliku,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _novaSlika != null
                                ? FileImage(_novaSlika!)
                                : (_trenutnaSlikaUrl != null &&
                                        _trenutnaSlikaUrl!.isNotEmpty)
                                    ? NetworkImage(_trenutnaSlikaUrl!)
                                    : const AssetImage("assets/images/user.png")
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
                          decoration:
                              const InputDecoration(labelText: 'Korisničko ime'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _savingProfil ? null : _spremiPromjeneProfila,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: Text(
                              _savingProfil ? "Spremanje..." : "Spremi promjene",
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===================== 2) LOZINKA =====================
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _trenutnaLozinkaController,
                          obscureText: !_isTrenutnaLozinkaVisible,
                          decoration: InputDecoration(
                            labelText: 'Trenutna lozinka',
                            suffixIcon: IconButton(
                              icon: Icon(_isTrenutnaLozinkaVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () => setState(() {
                                _isTrenutnaLozinkaVisible =
                                    !_isTrenutnaLozinkaVisible;
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _novaLozinkaController,
                          obscureText: !_isNovaLozinkaVisible,
                          decoration: InputDecoration(
                            labelText: 'Nova lozinka',
                            errorText: _novaLozinkaError,
                            suffixIcon: IconButton(
                              icon: Icon(_isNovaLozinkaVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () => setState(() {
                                _isNovaLozinkaVisible = !_isNovaLozinkaVisible;
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _potvrdiLozinkuController,
                          obscureText: !_isPotvrdiLozinkuVisible,
                          decoration: InputDecoration(
                            labelText: 'Potvrdi novu lozinku',
                            suffixIcon: IconButton(
                              icon: Icon(_isPotvrdiLozinkuVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () => setState(() {
                                _isPotvrdiLozinkuVisible =
                                    !_isPotvrdiLozinkuVisible;
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _savingPassword ? null : _promijeniLozinku,
                            icon: const Icon(Icons.password, color: Colors.white),
                            label: Text(
                              _savingPassword
                                  ? "Spremanje..."
                                  : "Spremi novu lozinku",
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===================== 3) PODRŠKA (SUPPORT) =====================
                  RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _ticketsFuture = _ticketService.getMyTickets();
                      });
                      await _ticketsFuture;
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          "Pošalji tiket podršci",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _subjectController,
                          decoration: const InputDecoration(
                            labelText: 'Naslov (Subject)',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _messageController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Poruka (Message)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _submittingTicket ? null : _posaljiTicket,
                            icon:
                                const Icon(Icons.send_rounded, color: Colors.white),
                            label: Text(
                              _submittingTicket ? "Slanje..." : "Pošalji tiket",
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Moji tiketi",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<List<SupportTicketModel>>(
                          future: _ticketsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text('Greška: ${snapshot.error}'),
                              );
                            }
                            final tickets = snapshot.data ?? [];
                            if (tickets.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text("Nemate kreiranih tiketa."),
                              );
                            }

                            return Column(
                              children: tickets.map((t) {
                                final created = t.createdAt;
                                final datum =
                                    "${created.day.toString().padLeft(2, '0')}.${created.month.toString().padLeft(2, '0')}.${created.year}";
                                final resolvedChip = t.isResolved
                                    ? Chip(
                                        label: const Text(
                                          "Riješen",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.green,
                                      )
                                    : Chip(
                                        label: const Text(
                                          "Otvoren",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.orange,
                                      );

                                return Card(
                                  color: Colors.grey[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                t.subject,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            resolvedChip,
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Kreiran: $datum",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          t.message,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (t.response != null &&
                                            t.response!.isNotEmpty) ...[
                                          const Divider(height: 18),
                                          Text(
                                            "Odgovor podrške:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: primary),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(t.response!),
                                        ]
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
