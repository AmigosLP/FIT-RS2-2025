import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _imeController = TextEditingController();
  final TextEditingController _prezimeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _trenutnaLozinkaController = TextEditingController();
  final TextEditingController _novaLozinkaController = TextEditingController();
  final TextEditingController _potvrdiLozinkuController = TextEditingController();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isTrenutnaLozinkaVisible = false;
  bool _isNovaLozinkaVisible = false;
  bool _isPotvrdiLozinkuVisible = false;

  String? _trenutniIme;
  String? _trenutniPrezime;
  String? _trenutniUsername;
  String? _trenutniEmail;
  String? _trenutniPhone;
  String? _trenutnaSlikaUrl;
  File? _novaSlika;

  String _imageBust = '';
  String _withCacheBust(String url) {
    if (url.isEmpty) return url;
    final sep = url.contains('?') ? '&' : '?';
    return _imageBust.isEmpty ? url : '$url${sep}v=$_imageBust';
  }

  String? _novaLozinkaError;
  String? _trenutnaLozinkaError;
  bool _loadingProfil = true;
  bool _savingProfil = false;
  bool _savingPassword = false;
  bool _submittingTicket = false;
  bool _removingImage = false;

  String? _usernameError;
  String? _emailError;

  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();

  late Future<List<SupportTicketModel>> _ticketsFuture;
  final _userService = UserService();
  final _ticketService = SupportTicketService();

  late final TabController _tabController;

  static const int _subjectMax = 100;
  static const int _messageMax = 300;

  final RegExp _nameAllowClass = RegExp(r"[A-Za-z\u00C0-\u017F \-]");
  final RegExp _nameRegex =
      RegExp(r"^[A-Za-z\u00C0-\u017F]+(?:[ -][A-Za-z\u00C0-\u017F]+)*$");

  String? _validateIme(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Ime je obavezno.';
    if (!_nameRegex.hasMatch(v)) {
      return "Dozvoljena su samo slova, razmak i '-' (bez brojeva i drugih znakova).";
    }
    return null;
  }

  String? _validatePrezime(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Prezime je obavezno.';
    if (!_nameRegex.hasMatch(v)) {
      return "Dozvoljena su samo slova, razmak i '-' (bez brojeva i drugih znakova).";
    }
    return null;
  }

bool _isValidEmail(String value) {
  final v = value.trim();
  final re = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,24}$'
  );
  return re.hasMatch(v);
}

  final RegExp _phoneAllowClass = RegExp(r"[0-9+\-\s()]");
  String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  String? _validatePhone(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Telefon je obavezan.';

    if (v.contains('+') && !v.startsWith('+')) {
      return "Znak '+' može biti samo na početku.";
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
    _phoneController.dispose();
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
        _phoneController.text = profil['phone'] ?? '';

        _trenutniIme = profil['firstName'];
        _trenutniPrezime = profil['lastName'];
        _trenutniUsername = profil['username'];
        _trenutniEmail = profil['email'];
        _trenutniPhone = profil['phone'];
        _trenutnaSlikaUrl = profil['profileImageUrl'];
        _loadingProfil = false;
      });
    } catch (e) {
      setState(() => _loadingProfil = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška pri učitavanju profila.")),
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

    setState(() {
      _usernameError = null;
      _emailError = null;
    });

    final form = _profileFormKey.currentState;
    if (form == null || !form.validate()) return;

    final imaPromjena = _imeController.text.trim() != (_trenutniIme ?? '') ||
        _prezimeController.text.trim() != (_trenutniPrezime ?? '') ||
        _usernameController.text.trim() != (_trenutniUsername ?? '') ||
        _emailController.text.trim() != (_trenutniEmail ?? '') ||
        _phoneController.text.trim() != (_trenutniPhone ?? '') ||
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

      await _userService.updateProfile(
        firstName: _imeController.text.trim(),
        lastName: _prezimeController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: '',
        profileImage: _novaSlika,
        userId: userId,
      );

      _trenutniIme = _imeController.text.trim();
      _trenutniPrezime = _prezimeController.text.trim();
      _trenutniUsername = _usernameController.text.trim();
      _trenutniEmail = _emailController.text.trim();
      _trenutniPhone = _phoneController.text.trim();

      await _ucitajProfil();

      if (mounted) {
        setState(() {
          _novaSlika = null;
          _imageBust = DateTime.now().millisecondsSinceEpoch.toString();
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil uspješno ažuriran."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final raw = e.toString().replaceFirst('Exception: ', '').toLowerCase();
      bool handled = false;

      if (raw.contains('email')) {
        setState(() {
          _emailError = "Ovaj email je već zauzet. Pokušajte s drugim.";
        });
        handled = true;
      }
      if (raw.contains('username') ||
          raw.contains('korisničko ime') ||
          raw.contains('korisničkim imenom')) {
        setState(() {
          _usernameError = "Korisničko ime je zauzeto. Odaberite neko drugo.";
        });
        handled = true;
      }
  

      if (!handled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Došlo je do greške pri spremanju. Pokušajte ponovo."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingProfil = false);
    }
  }

  Future<void> _promijeniLozinku() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _trenutnaLozinkaError = null;
    });

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
    final lozinkaValidna =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$')
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

      final raw = e.toString().replaceFirst('Exception: ', '').toLowerCase();

      if (raw.contains('current password') ||
          raw.contains('incorrect password') ||
          raw.contains('invalid password') ||
          raw.contains('old password') ||
          raw.contains('stara lozinka') ||
          raw.contains('trenutna lozinka') ||
          raw.contains('pogrešn')) {
        setState(() {
          _trenutnaLozinkaError = "Trenutna lozinka nije tačna.";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Greška: nije moguće promijeniti lozinku u ovom trenutku."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  Future<void> _posaljiTicket() async {
    FocusScope.of(context).unfocus();

    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unesite naslov tiketa.")),
      );
      return;
    }
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unesite poruku tiketa.")),
      );
      return;
    }
    if (subject.length > _subjectMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Naslov može imati najviše $_subjectMax znakova.")),
      );
      return;
    }
    if (message.length > _messageMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Poruka može imati najviše $_messageMax znakova.")),
      );
      return;
    }

    setState(() => _submittingTicket = true);
    try {
      await _ticketService.createTicket(subject: subject, message: message);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tiket je uspješno poslan."),
          backgroundColor: Colors.green,
        ),
      );

      _subjectController.clear();
      _messageController.clear();

      setState(() {
        _ticketsFuture = _ticketService.getMyTickets();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Greška pri slanju tiketa."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submittingTicket = false);
    }
  }

  Future<void> _potvrdiUklanjanjeSlike() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ukloniti profilnu sliku?'),
        content: const Text('Ova radnja će ukloniti sliku i postaviti default placeholder.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Odustani'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Ukloni'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _ukloniSliku();
    }
  }

  Future<void> _ukloniSliku() async {
    setState(() => _removingImage = true);
    try {
      await _userService.removeProfileImage();
      await _ucitajProfil();

      if (!mounted) return;
      setState(() {
        _novaSlika = null;
        _trenutnaSlikaUrl = null;
        _imageBust = DateTime.now().millisecondsSinceEpoch.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profilna slika uklonjena.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Greška pri uklanjanju.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _removingImage = false);
    }
  }

  Widget _ticketCard(SupportTicketModel t, Color primary) {
    final created = t.createdAt;
    final datum =
        "${created.day.toString().padLeft(2, '0')}.${created.month.toString().padLeft(2, '0')}.${created.year}";
    final resolvedChip = t.isResolved
        ? const Chip(
            label: Text("Riješen", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          )
        : const Chip(
            label: Text("Otvoren", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.orange,
          );

    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    t.subject,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                resolvedChip,
              ],
            ),
            const SizedBox(height: 6),
            Text("Kreiran: $datum",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            Text(t.message, maxLines: 3, overflow: TextOverflow.ellipsis),
            if (t.response != null && t.response!.isNotEmpty) ...[
              const Divider(height: 18),
              Text("Odgovor podrške:",
                  style: TextStyle(fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 6),
              Text(t.response!),
            ]
          ],
        ),
      ),
    );
  }

  void _openAllTicketsSheet(List<SupportTicketModel> tickets, Color primary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        final height = MediaQuery.of(context).size.height * 0.75;
        return Container(
          height: height,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text("Svi tiketi",
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 0),
                  itemBuilder: (context, index) => _ticketCard(tickets[index], primary),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _profileFormKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              GestureDetector(
                                onTap: _odaberiNovuSliku,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: _novaSlika != null
                                      ? FileImage(_novaSlika!)
                                      : (_trenutnaSlikaUrl != null &&
                                              _trenutnaSlikaUrl!.isNotEmpty)
                                          ? NetworkImage(_withCacheBust(_trenutnaSlikaUrl!))
                                          : const AssetImage("assets/images/user.png")
                                              as ImageProvider,
                                ),
                              ),
                              if (_novaSlika != null ||
                                  (_trenutnaSlikaUrl != null &&
                                      _trenutnaSlikaUrl!.isNotEmpty))
                                Padding(
                                  padding: const EdgeInsets.only(right: 2, bottom: 2),
                                  child: InkWell(
                                    onTap: _removingImage ? null : _potvrdiUklanjanjeSlike,
                                    customBorder: const CircleBorder(),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _removingImage ? Colors.grey : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(Icons.delete,
                                          color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _odaberiNovuSliku,
                                icon: const Icon(Icons.photo),
                                label: const Text('Promijeni'),
                              ),
                              const SizedBox(width: 12),
                              TextButton.icon(
                                onPressed: (_novaSlika != null ||
                                        (_trenutnaSlikaUrl != null &&
                                            _trenutnaSlikaUrl!.isNotEmpty))
                                    ? (_removingImage ? null : _potvrdiUklanjanjeSlike)
                                    : null,
                                icon: const Icon(Icons.delete_outline),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                label: Text(_removingImage ? 'Uklanjam...' : 'Ukloni'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _imeController,
                            decoration: const InputDecoration(
                              labelText: 'Ime',
                              hintText: "Maksimalno 50 karaktera",
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(_nameAllowClass),
                              LengthLimitingTextInputFormatter(50),
                            ],
                            validator: _validateIme,
                          ),
                          const SizedBox(height: 10),

                          TextFormField(
                            controller: _prezimeController,
                            decoration: const InputDecoration(
                              labelText: 'Prezime',
                              hintText: "Maksimalno 50 karaktera",
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(_nameAllowClass),
                              LengthLimitingTextInputFormatter(50),
                            ],
                            validator: _validatePrezime,
                          ),
                          const SizedBox(height: 10),

                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Korisničko ime',
                              hintText: "Maksimalno 30 karaktera",
                              errorText: _usernameError,
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(30),
                            ],
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Korisničko ime je obavezno.'
                                    : null,
                            onChanged: (_) {
                              if (_usernameError != null) {
                                setState(() => _usernameError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 10),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              errorText: _emailError,
                            ),
                            validator: (value) {
                              final v = (value ?? '').trim();
                              if (v.isEmpty) return 'Email je obavezan.';
                              if (!_isValidEmail(v)) {
                                return 'Unesite ispravan email (npr. ime@domena.com).';
                              }
                              return null;
                            },
                            onChanged: (_) {
                              if (_emailError != null) {
                                setState(() => _emailError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 10),

                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Telefon',
                              hintText: "+387 62 123 456",
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(_phoneAllowClass),
                              LengthLimitingTextInputFormatter(20),
                            ],
                            validator: _validatePhone,
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
                  ),

                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _trenutnaLozinkaController,
                          obscureText: !_isTrenutnaLozinkaVisible,
                          decoration: InputDecoration(
                            labelText: 'Trenutna lozinka',
                            errorText: _trenutnaLozinkaError,
                            suffixIcon: IconButton(
                              icon: Icon(_isTrenutnaLozinkaVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () => setState(
                                  () => _isTrenutnaLozinkaVisible = !_isTrenutnaLozinkaVisible),
                            ),
                          ),
                          onChanged: (_) {
                            if (_trenutnaLozinkaError != null) {
                              setState(() => _trenutnaLozinkaError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _novaLozinkaController,
                          obscureText: !_isNovaLozinkaVisible,
                          decoration: InputDecoration(
                            labelText: 'Nova lozinka',
                            errorText: _novaLozinkaError,
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _isNovaLozinkaVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(
                                  () => _isNovaLozinkaVisible = !_isNovaLozinkaVisible),
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
                              onPressed: () => setState(
                                  () => _isPotvrdiLozinkuVisible = !_isPotvrdiLozinkuVisible),
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
                              _savingPassword ? "Spremanje..." : "Spremi novu lozinku",
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
                            color: primary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: _subjectController,
                          maxLength: _subjectMax,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          inputFormatters: [LengthLimitingTextInputFormatter(_subjectMax)],
                          decoration: InputDecoration(
                            labelText: 'Naslov',
                            counterStyle: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        const SizedBox(height: 10),

                        TextField(
                          controller: _messageController,
                          maxLines: 5,
                          maxLength: _messageMax,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          inputFormatters: [LengthLimitingTextInputFormatter(_messageMax)],
                          decoration: InputDecoration(
                            labelText: 'Poruka',
                            alignLabelWithHint: true,
                            counterStyle: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _submittingTicket ? null : _posaljiTicket,
                            icon: const Icon(Icons.send_rounded, color: Colors.white),
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
                            color: primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<List<SupportTicketModel>>(
                          future: _ticketsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text('Greška pri učitavanju tiketa.'),
                              );
                            }
                            final tickets = snapshot.data ?? [];
                            if (tickets.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text("Nemate kreiranih tiketa."),
                              );
                            }

                            final preview =
                                tickets.length > 2 ? tickets.take(2).toList() : tickets;

                            return Column(
                              children: [
                                ...preview.map((t) => _ticketCard(t, primary)),
                                if (tickets.length > 2)
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      "Prikaži više tiketa...",
                                      style: TextStyle(
                                        color: primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    trailing: Icon(Icons.expand_more, color: primary),
                                    onTap: () => _openAllTicketsSheet(tickets, primary),
                                  ),
                              ],
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
