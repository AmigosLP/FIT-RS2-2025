import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:zamene_desktop/models/property_create_model.dart';

class NekretnineScreen extends StatefulWidget {
  const NekretnineScreen({Key? key}) : super(key: key);

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

  Future<void> ucitajNekretnine() async {
    final uri = Uri.parse('http://localhost:5283/api/Property/with-images');
    final headers = await getAuthHeader();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      setState(() {
        topPonude = data.map<Map<String, dynamic>>((item) {
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
            'slika': (item['imageUrls'] != null && (item['imageUrls'] as List).isNotEmpty)
                ? item['imageUrls'][0]
                : '',
            'slike': item['imageUrls'] ?? [],
          };
        }).toList();

        filteredPonude = List.from(topPonude);
      });
    } else {
      print('Greška pri dohvaćanju nekretnina: ${response.statusCode}');
    }
  }

  void _filtrirajPonude(String query) {
    setState(() {
      filteredPonude = topPonude.where((ponuda) {
        return ponuda['naziv']!.toLowerCase().contains(query.toLowerCase()) ||
            ponuda['grad']!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<Map<String, String>> getAuthHeader() async {
    const secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: "token");
    print("Token iz storage-a: $token");
    return {"Authorization": "Bearer $token"};
  }

  Future<void> posaljiNaBackend(PropertyCreateModel model) async {
    final uri = Uri.parse("http://localhost:5283/api/Property/create-with-images");
    final request = http.MultipartRequest('POST', uri);

    final headers = await getAuthHeader();
    request.headers.addAll(headers);

    await model.dodaj(request);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (isValidResponse(response)) {
      print("Uspješno poslan zahtjev na backend");
      await ucitajNekretnine();
    } else {
      print("Greška prilikom slanja na backend: ${response.statusCode}");
    }
  }

  Future<void> obrisiNekretninu(int id) async {
  final uri = Uri.parse('http://localhost:5283/api/Property/$id');
  final headers = await getAuthHeader();

  final response = await http.delete(uri, headers: headers);

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

  bool isValidResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      final errorBody = jsonDecode(response.body);
      final message = errorBody['message'] ?? "Došlo je do greške. Pokušajte ponovo.";
      throw message;
    } else if (response.statusCode >= 500) {
      throw "Greška na serveru. Pokušajte kasnije.";
    } else {
      throw "Neočekivana greška. Pokušajte ponovo.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administracija Nekretnina")),
      body: SingleChildScrollView(
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
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3 / 2,
              children: filteredPonude.map((ponuda) {
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
          //               ClipRRect(
          //   borderRadius: const BorderRadius.only(
          //     topLeft: Radius.circular(15.0),
          //     topRight: Radius.circular(15.0),
          //   ),
          //   child: Container(
          //     width: double.infinity,
          //     height: 350.0,
          //     color: Colors.grey[300],
          //     child: Image(
          //       image: ponuda['slika'] != null && ponuda['slika'].toString().isNotEmpty
          //               ? Image.network(
          //                ponuda['slika'],) : '',
          //       fit: BoxFit.fill,
          //     ),
          //   ),
          // ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                            child: ponuda['slika'].toString().isNotEmpty
                                ? Image.network(
                                    ponuda['slika'],
                                    height: 80,
                                    width: double.infinity,
                                    fit: BoxFit.fill,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image, size: 40),
                                      );
                                    },
                                  )
                                : Container(
                                    height: 80,
                                    color: Colors.blue[300],
                                    child: const Icon(Icons.image, size: 40),
                                  ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          ponuda['naziv'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        Text("Cijena: ${ponuda['cijena'] ?? ''}"),
                        Text("Grad: ${ponuda['grad'] ?? ''}"),
                        Text("Kvadratura: ${ponuda['kvadratura'] ?? ''} m²"),
                        const SizedBox(height: 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text("Uredi"),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(100, 40),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // TODO: Dodaj funkcionalnost za uređivanje
                                print("Kliknuto Uredi na nekretnini ID: ${ponuda['id']}");
                              },
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.delete),
                              label: const Text("Obriši"),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(100, 40),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Potvrda"),
                                    content: const Text("Da li ste sigurni da zelite obrisati ovu nekretninu?"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Ne"),
                                        onPressed: () => Navigator.pop(context, false),
                                      ),
                                      TextButton(
                                        child: const Text("Da"),
                                        onPressed: () => Navigator.pop(context, true),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await obrisiNekretninu(ponuda['id']);
                                  ucitajNekretnine();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
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
  const DodajNekretninuForma({Key? key, required this.onSubmitted}) : super(key: key);

  @override
  State<DodajNekretninuForma> createState() => _DodajNekretninuFormaState();
}

class _DodajNekretninuFormaState extends State<DodajNekretninuForma> {
  final _formKey = GlobalKey<FormState>();
  final nazivController = TextEditingController();
  final cijenaController = TextEditingController();
  final spavaceSobeController = TextEditingController();
  final toaletController = TextEditingController();
  final gradController = TextEditingController();
  final opisController = TextEditingController();
  final adresaController = TextEditingController();
  final drzavaController = TextEditingController();
  final kvadraturaController = TextEditingController();
  List<File> _slike = [];

  Future<void> _odaberiSlike() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _slike = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<Map<String, String>> getAuthHeader() async {
    const secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: "token");
    return {"Authorization": "Bearer $token"};
  }

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

    final model = PropertyCreateModel(
      title: nazivController.text,
      description: opisController.text,
      price: double.parse(cijenaController.text),
      address: adresaController.text,
      city: gradController.text,
      country: drzavaController.text,
      agentId: 1, // ako koristiš dinamički agentId, zamijeni
      roomCount: int.parse(spavaceSobeController.text),
      area: double.parse(kvadraturaController.text),
      images: _slike,
    );

    final uri = Uri.parse("http://localhost:5283/api/Property/create-with-images");
    final request = http.MultipartRequest('POST', uri);
    final headers = await getAuthHeader();
    request.headers.addAll(headers);
    await model.dodaj(request);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (isValidResponse(response)) {
      print("Uspješno poslan zahtjev na backend");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nekretnina je uspješno dodana."),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSubmitted();
    } else {
      print("Greška pri slanju: ${response.statusCode}");
    }
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      final errorBody = jsonDecode(response.body);
      final message = errorBody['message'] ?? "Došlo je do greške. Pokušajte ponovo.";
      throw message;
    } else if (response.statusCode >= 500) {
      throw "Greška na serveru. Pokušajte kasnije.";
    } else {
      throw "Neočekivana greška. Pokušajte ponovo.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                  decoration: const InputDecoration(labelText: "Naziv"),
                  validator: (value) => (value == null || value.isEmpty) ? "Unesite naziv" : null,
                ),
                TextFormField(
                  controller: cijenaController,
                  decoration: const InputDecoration(labelText: "Cijena (KM)"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Unesite cijenu";
                    if (double.tryParse(value) == null) return "Unesite ispravan broj";
                    return null;
                  },
                ),
                TextFormField(
                  controller: spavaceSobeController,
                  decoration: const InputDecoration(labelText: "Broj spavaćih soba"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Unesite broj soba";
                    if (int.tryParse(value) == null) return "Unesite ispravan broj";
                    return null;
                  },
                ),
                TextFormField(
                  controller: kvadraturaController,
                  decoration: const InputDecoration(labelText: "Kvadratura (m²)"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Unesite kvadraturu";
                    if (double.tryParse(value) == null) return "Unesite ispravan broj";
                    return null;
                  },
                ),
                TextFormField(
                  controller: gradController,
                  decoration: const InputDecoration(labelText: "Grad"),
                  validator: (value) => (value == null || value.isEmpty) ? "Unesite grad" : null,
                ),
                TextFormField(
                  controller: drzavaController,
                  decoration: const InputDecoration(labelText: "Država"),
                  validator: (value) => (value == null || value.isEmpty) ? "Unesite državu" : null,
                ),
                TextFormField(
                  controller: adresaController,
                  decoration: const InputDecoration(labelText: "Adresa"),
                  validator: (value) => (value == null || value.isEmpty) ? "Unesite adresu" : null,
                ),
                TextFormField(
                  controller: opisController,
                  decoration: const InputDecoration(labelText: "Opis"),
                  maxLines: 3,
                  validator: (value) => (value == null || value.isEmpty) ? "Unesite opis" : null,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Odaberi slike"),
                  onPressed: _odaberiSlike,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _slike.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.file(_slike[index], width: 100, fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _posaljiNaBackend,
                  child: const Text("Spremi nekretninu"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
