import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:zamene_desktop/forms/edit_property_form.dart';
import 'package:zamene_desktop/models/city_desktop_model.dart';
import 'package:zamene_desktop/models/country_desktop_model.dart';
import 'package:zamene_desktop/providers/city_provider.dart';
import 'package:zamene_desktop/providers/country_provider.dart';

class NekretnineScreen extends StatefulWidget {
  const NekretnineScreen({super.key});

  @override
  State<NekretnineScreen> createState() => _NekretnineScreenState();
}

class _NekretnineScreenState extends State<NekretnineScreen> {
  List<Map<String, dynamic>> topPonude = [];
  List<Map<String, dynamic>> filteredPonude = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ucitajNekretnine();
  }

  String getBaseImageUrl() {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:5283";
    } else {
      return "http://localhost:5283";
    }
  }

  String fixImageUrl(String url) {
    if (url.startsWith('http')) return url;
    return getBaseImageUrl() + url;
  }

  Future<Map<String, String>> getAuthHeader() async {
    const secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: "token");
    return {"Authorization": "Bearer $token"};
  }

  Future<void> ucitajNekretnine() async {
    const baseImageUrl = 'http://localhost:5283';
    String _absUrl(String? u) {
      if (u == null || u.isEmpty) return '';
      final s = u.replaceAll('\\', '/');
      if (s.startsWith('http')) return s;
      return '$baseImageUrl${s.startsWith('/') ? '' : '/'}$s';
    }

    try {
      final uri = Uri.parse('$baseImageUrl/api/Property/with-images');
      final headers = await getAuthHeader();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode != 200) {
        print('Greška pri dohvaćanju nekretnina: ${response.statusCode}');
        return;
      }

      final List<dynamic> data = jsonDecode(response.body);

      setState(() {
        topPonude = data.map<Map<String, dynamic>>((item) {
          final List raw = (item['images'] ?? item['imageUrls'] ?? []) as List;

          final List<Map<String, dynamic>> normImages =
              raw.map<Map<String, dynamic>>((e) {
            if (e is Map) {
              return {
                'id': e['id'],
                'url': _absUrl(e['url']?.toString() ?? ''),
              };
            } else if (e is String) {
              return {
                'id': null,
                'url': _absUrl(e),
              };
            }
            return {'id': null, 'url': ''};
          }).where((m) => (m['url'] as String).isNotEmpty).toList();

          final String slika =
              normImages.isNotEmpty ? (normImages.first['url'] as String) : '';

          return {
            'id': item['propertyID'],
            'naziv': item['title'] ?? '',
            'opis': item['description'] ?? '',
            'cijena': '${item['price']} KM',
            'grad': item['city'] ?? '',
            'drzava': item['country'] ?? '',
            'adresa': item['address'] ?? '',
            'agentId': item['agentID'],
            'sobe': item['roomCount'],
            'kvadratura': item['area'],
            'slika': slika,
            'slike': normImages,
          };
        }).toList();

        filteredPonude = List.from(topPonude);
      });
    } catch (e) {
      print('Greška pri dohvaćanju nekretnina: $e');
    }
  }

  void _filtrirajPonude(String query) {
    setState(() {
      filteredPonude = topPonude.where((ponuda) {
        return (ponuda['naziv'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            (ponuda['grad'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> obrisiNekretninu(int id) async {
    final uri = Uri.parse('${getBaseImageUrl()}/api/Property/custom-delete/$id');
    final headers = await getAuthHeader();

    final response = await http.delete(uri, headers: headers);

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nekretnina uspješno obrisana.'),
          backgroundColor: Colors.green,
        ),
      );
      await ucitajNekretnine();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri brisanju: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _ikonicaSaTekstom(IconData ikon, String tekst) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ikon, size: 18, color: Colors.blueGrey[700]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            tekst,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administracija Nekretnina")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Pretraži po nazivu ili gradu",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filtrirajPonude,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 3;

                  if (constraints.maxWidth < 800) {
                    crossAxisCount = 1;
                  } else if (constraints.maxWidth < 1200) {
                    crossAxisCount = 2;
                  }

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                    children: filteredPonude.map((ponuda) {
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: LayoutBuilder(
                            builder: (context, cardConstraints) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      height: cardConstraints.maxWidth * 0.6,
                                      width: double.infinity,
                                      color: Colors.grey[200],
                                      child: (ponuda['slika'] as String).isNotEmpty
                                          ? Image.network(
                                              ponuda['slika'] as String,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error,
                                                    size: 40),
                                              ),
                                            )
                                          : Container(
                                              color: Colors.blue[300],
                                              child: const Icon(Icons.image,
                                                  size: 40),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            cardConstraints.maxWidth * 0.9),
                                    child: Text(
                                      ponuda['naziv'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      _ikonicaSaTekstom(Icons.monetization_on,
                                          ponuda['cijena'] ?? ''),
                                      _ikonicaSaTekstom(
                                          Icons.square_foot,
                                          '${ponuda['kvadratura'] ?? ''} m²'),
                                      _ikonicaSaTekstom(
                                          Icons.location_on,
                                          '${ponuda['grad'] ?? ''}, ${ponuda['drzava'] ?? ''}'),
                                      _ikonicaSaTekstom(
                                          Icons.description,
                                          ponuda['opis'] ?? ''),
                                    ],
                                  ),
                                  const Spacer(),
                                  Wrap(
                                    spacing: 16,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.edit),
                                        label: const Text("Uredi"),
                                        onPressed: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: UrediNekretninuForma(
                                                nekretnina: ponuda,
                                                onUpdated: () {
                                                  Navigator.pop(context);
                                                  ucitajNekretnine();
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.delete),
                                        label: const Text("Obriši"),
                                        onPressed: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text("Potvrda"),
                                              content: const Text(
                                                  "Da li ste sigurni da želite obrisati ovu nekretninu?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    child: const Text("Ne")),
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, true),
                                                    child: const Text("Da")),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await obrisiNekretninu(
                                                ponuda['id'] as int);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: DodajNekretninuForma(
                onSubmitted: () {
                  Navigator.pop(context);
                  ucitajNekretnine();
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DodajNekretninuForma extends StatefulWidget {
  final VoidCallback onSubmitted;
  const DodajNekretninuForma({Key? key, required this.onSubmitted})
      : super(key: key);

  @override
  State<DodajNekretninuForma> createState() => _DodajNekretninuFormaState();
}

class _DodajNekretninuFormaState extends State<DodajNekretninuForma> {
  final _formKey = GlobalKey<FormState>();
  final nazivController = TextEditingController();
  final cijenaController = TextEditingController();
  final spavaceSobeController = TextEditingController();
  final opisController = TextEditingController();
  final adresaController = TextEditingController();

  final CityService cityService = CityService();
  List<CityDesktopModel> gradovi = [];
  CityDesktopModel? odabraniGrad;
  bool ucitavanjeGradova = true;

  final CountryService countryService = CountryService();
  List<CountryDesktopModel> drzave = [];
  CountryDesktopModel? odabranaDrzava;
  bool ucitavanjeDrzava = true;

  final List<File> _slike = [];

  static const int _maxImages = 8;

  final ScrollController _thumbsCtrl = ScrollController();
  static const double _tileSize = 130.0;
  static const double _tileGap = 10.0;

  bool _saving = false;

  final _rexNaziv = RegExp(r"^[A-Za-zÀ-ÿ0-9\s\-\.,'’]{3,100}$");
  final _rexAdresa = RegExp(r"^[A-Za-zÀ-ÿ0-9\s\-\./,']{5,120}$");
  final _rexImaSlovo = RegExp(r"[A-Za-zÀ-ÿ]");

  String? _validateNaziv(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return "Unesite naziv";
    if (value.length < 3) return "Naziv mora imati najmanje 3 znaka";
    if (value.length > 100) return "Naziv može imati najviše 100 znakova";
    if (!_rexNaziv.hasMatch(value)) {
      return "Dozvoljena su slova, brojevi, razmak, -, ., , i apostrof";
    }
    return null;
  }

  String? _validateCijena(String? v) {
    final value = (v ?? '').trim().replaceAll(',', '.');
    if (value.isEmpty) return "Unesite cijenu";
    final num? parsed = num.tryParse(value);
    if (parsed == null) return "Cijena mora biti broj (npr. 250 ili 250.50)";
    if (parsed <= 0) return "Cijena mora biti veća od 0";
    if (parsed > 10000000) return "Cijena je nerealno velika";
    return null;
  }

  String? _validateGrad(CityDesktopModel? v) {
    if (v == null) return "Odaberite grad";
    return null;
  }

  String? _validateDrzava(CountryDesktopModel? v) {
    if (v == null) return "Odaberite državu";
    return null;
  }

  String? _validateAdresa(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return "Unesite adresu";
    if (value.length < 5) return "Adresa mora imati najmanje 5 znakova";
    if (value.length > 120) return "Adresa može imati najviše 120 znakova";
    if (!_rexAdresa.hasMatch(value)) {
      return "Dozvoljena su slova, brojevi, razmak, ., -, / i apostrof";
    }
    if (!_rexImaSlovo.hasMatch(value)) {
      return "Adresa mora sadržavati barem jedno slovo";
    }
    return null;
  }

  String? _validateOpis(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return "Unesite opis";
    if (value.length < 10) return "Opis mora imati najmanje 10 znakova";
    if (value.length > 1000) return "Opis može imati najviše 1000 znakova";
    return null;
  }

  @override
  void initState() {
    super.initState();
    ucitajGradove();
    ucitajDrzave();
  }

  @override
  void dispose() {
    nazivController.dispose();
    cijenaController.dispose();
    spavaceSobeController.dispose();
    opisController.dispose();
    adresaController.dispose();
    _thumbsCtrl.dispose();
    super.dispose();
  }

  Future<void> ucitajGradove() async {
    try {
      final result = await cityService.fetchGradove();
      setState(() {
        gradovi = result;
        ucitavanjeGradova = false;
      });
    } catch (e) {
      print("Greška prilikom učitavanja gradova: $e");
      setState(() => ucitavanjeGradova = false);
    }
  }

  Future<void> ucitajDrzave() async {
    try {
      final result = await countryService.fetchCountries();
      setState(() {
        drzave = result;
        ucitavanjeDrzava = false;
      });
    } catch (e) {
      print("Greška prilikom učitavanja država: $e");
      setState(() => ucitavanjeDrzava = false);
    }
  }

  Future<void> odaberiSlike() async {
    final remaining = _maxImages - _slike.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimalno je dozvoljeno 8 slika.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles == null || pickedFiles.isEmpty) return;

    final addThese =
        pickedFiles.take(remaining).map((e) => File(e.path)).toList();

    setState(() {
      _slike.addAll(addThese);
    });

    if (pickedFiles.length > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Dodano ${addThese.length} od ${pickedFiles.length} odabranih (maks. $_maxImages).'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    await Future.delayed(const Duration(milliseconds: 50));
    if (_thumbsCtrl.hasClients) {
      _thumbsCtrl.animateTo(
        _thumbsCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  String _baseUrl() =>
      Platform.isAndroid ? "http://10.0.2.2:5283" : "http://localhost:5283";

  Future<void> _posaljiNaBackend() async {
    if (!_formKey.currentState!.validate() || _slike.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Molimo popunite sva polja i odaberite slike."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      const secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: "token");
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Niste prijavljeni"), backgroundColor: Colors.red),
        );
        return;
      }

      final uri = Uri.parse("${_baseUrl()}/api/Property/create-with-images");
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = "Bearer $token"
        ..fields['Title'] = nazivController.text.trim()
        ..fields['Description'] = opisController.text.trim()
        ..fields['Price'] = cijenaController.text.trim().replaceAll(',', '.')
        ..fields['Address'] = adresaController.text.trim()
        ..fields['City'] = (odabraniGrad?.name ?? '').trim()
        ..fields['Country'] = (odabranaDrzava?.name ?? '').trim()
        ..fields['AgentID'] = "1"
        ..fields['RoomCount'] = spavaceSobeController.text.trim()
        ..fields['Area'] = "0";

      final filesToSend = _slike.take(_maxImages).toList();
      for (final f in filesToSend) {
        req.files.add(await http.MultipartFile.fromPath('Images', f.path));
      }

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Nekretnina je uspješno dodana."),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSubmitted();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Greška pri slanju (${resp.statusCode}): ${resp.body}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _scrollBy(double delta) {
    if (!_thumbsCtrl.hasClients) return;
    final double target = math.max(
        0.0,
        math.min(
            _thumbsCtrl.offset + delta, _thumbsCtrl.position.maxScrollExtent));
    _thumbsCtrl.animateTo(target,
        duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  Widget _buildScroller({
    required List<Widget> tiles,
    required double availableWidth,
    required Color arrowColor,
  }) {
    final int visible =
        math.max(1, (availableWidth / (_tileSize + _tileGap)).floor());
    final bool showArrows = tiles.length > visible;

    return SizedBox(
      height: _tileSize + 10,
      width: double.infinity,
      child: Stack(
        children: [
          Scrollbar(
            controller: _thumbsCtrl,
            thumbVisibility: showArrows,
            child: SingleChildScrollView(
              controller: _thumbsCtrl,
              scrollDirection: Axis.horizontal,
              child: Row(children: tiles),
            ),
          ),
          if (showArrows)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _ScrollButton(
                right: false,
                color: arrowColor,
                onTap: () => _scrollBy(-(_tileSize * 2)),
              ),
            ),
          if (showArrows)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _ScrollButton(
                right: true,
                color: arrowColor,
                onTap: () => _scrollBy(_tileSize * 2),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 600,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Dodaj novu nekretninu",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: nazivController,
                  decoration: const InputDecoration(
                    labelText: "Naziv",
                    hintText: "npr. Moderan stan u centru",
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r"[A-Za-zÀ-ÿ0-9\s\-\.,'’]")),
                    LengthLimitingTextInputFormatter(100),
                  ],
                  validator: _validateNaziv,
                ),

                TextFormField(
                  controller: cijenaController,
                  decoration: const InputDecoration(
                    labelText: "Cijena (KM)",
                    hintText: "npr. 250 ili 250,50",
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[0-9\.,]")),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  validator: _validateCijena,
                ),

                TextFormField(
                  controller: spavaceSobeController,
                  decoration:
                      const InputDecoration(labelText: "Broj spavaćih soba"),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Unesite broj soba";
                    }
                    final n = int.tryParse(value);
                    if (n == null) return "Unesite ispravan broj";
                    if (n < 0) return "Broj soba ne može biti negativan";
                    if (n > 50) return "Unesite realan broj soba";
                    return null;
                  },
                ),

                ucitavanjeGradova
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<CityDesktopModel>(
                        decoration: const InputDecoration(labelText: "Grad"),
                        value: odabraniGrad,
                        items: gradovi.map((city) {
                          return DropdownMenuItem<CityDesktopModel>(
                            value: city,
                            child: Text(city.name),
                          );
                        }).toList(),
                        onChanged: (CityDesktopModel? newValue) {
                          setState(() {
                            odabraniGrad = newValue;
                          });
                        },
                        validator: (value) => _validateGrad(value),
                      ),

                ucitavanjeDrzava
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<CountryDesktopModel>(
                        decoration: const InputDecoration(labelText: "Država"),
                        value: odabranaDrzava,
                        items: drzave.map((drzava) {
                          return DropdownMenuItem<CountryDesktopModel>(
                            value: drzava,
                            child: Text(drzava.name),
                          );
                        }).toList(),
                        onChanged: (CountryDesktopModel? newValue) {
                          setState(() {
                            odabranaDrzava = newValue;
                          });
                        },
                        validator: (value) => _validateDrzava(value),
                      ),

                TextFormField(
                  controller: adresaController,
                  decoration: const InputDecoration(
                    labelText: "Adresa",
                    hintText: "npr. Ulica bb 10",
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r"[A-Za-zÀ-ÿ0-9\s\-\./,']")),
                    LengthLimitingTextInputFormatter(120),
                  ],
                  validator: _validateAdresa,
                ),

                TextFormField(
                  controller: opisController,
                  decoration: const InputDecoration(
                    labelText: "Opis",
                    hintText: "Kratak opis nekretnine...",
                  ),
                  maxLines: 3,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1000),
                  ],
                  validator: _validateOpis,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Odaberi slike"),
                      onPressed:
                          _slike.length >= _maxImages ? null : odaberiSlike,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_slike.length}/$_maxImages',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    if (_slike.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Još niste odabrali slike'),
                        ),
                      );
                    }

                    final tiles = List.generate(_slike.length, (i) {
                      final slika = _slike[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: _tileGap),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                slika,
                                width: _tileSize,
                                height: _tileSize,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: _CircleIconButton(
                                icon: Icons.close,
                                onTap: () =>
                                    setState(() => _slike.removeAt(i)),
                                bgColor: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    });

                    return _buildScroller(
                      tiles: tiles,
                      availableWidth: constraints.maxWidth,
                      arrowColor: primary,
                    );
                  },
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Dodaj nekretninu"),
                  onPressed: _saving ? null : _posaljiNaBackend,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScrollButton extends StatelessWidget {
  final bool right;
  final VoidCallback onTap;
  final Color color;
  const _ScrollButton(
      {required this.right, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: color.withOpacity(0.92),
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(right ? Icons.chevron_right : Icons.chevron_left,
                color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color bgColor;
  const _CircleIconButton(
      {required this.icon, required this.onTap, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
