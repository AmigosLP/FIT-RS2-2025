import 'package:flutter/material.dart';
import 'package:zamene_desktop/layouts/master_screen.dart';

class NekretnineScreen extends StatefulWidget {
  @override
  _NekretnineScreenState createState() => _NekretnineScreenState();
}

class _NekretnineScreenState extends State<NekretnineScreen> {
  final List<Map<String, String>> topPonude = [
    {
      'naziv': 'Stan Mostar Centar',
      'cijena': '800 KM',
      'slika': 'assets/images/mostar.jpg',
      'spavaceSobe': '2',
      'toalet': '1',
      'grad': 'Mostar'
    },
    {
      'naziv': 'Apartman Sarajevo',
      'cijena': '1200 KM',
      'slika': 'assets/images/sarajevo.jpg',
      'spavaceSobe': '3',
      'toalet': '2',
      'grad': 'Sarajevo'
    },
    {
      'naziv': 'Garsonjera Banja Luka',
      'cijena': '500 KM',
      'slika': 'assets/images/banjaluka.jpg',
      'spavaceSobe': '1',
      'toalet': '1',
      'grad': 'Banja Luka'
    },
    {
      'naziv': 'Apartman Zenica',
      'cijena': '600 KM',
      'slika': 'assets/images/zenica.jpg',
      'spavaceSobe': '2',
      'toalet': '1',
      'grad': 'Zenica'
    },
    {
      'naziv': 'Studio Tuzla',
      'cijena': '400 KM',
      'slika': 'assets/images/tuzla.jpg',
      'spavaceSobe': '1',
      'toalet': '1',
      'grad': 'Tuzla'
    },
    {
      'naziv': 'Vila Trebinje',
      'cijena': '2000 KM',
      'slika': 'assets/images/trebinje.jpg',
      'spavaceSobe': '4',
      'toalet': '3',
      'grad': 'Trebinje'
    },
  ];

  List<Map<String, String>> filteredPonude = [];
  String filter = "";
  bool showingTopPonuda = false;

  @override
  void initState() {
    super.initState();
    filteredPonude = List.from(topPonude);
  }

  void filterPonude(String value) {
    setState(() {
      filter = value;
      filteredPonude = topPonude
          .where((ponuda) =>
              ponuda['naziv']!.toLowerCase().contains(value.toLowerCase()))
          .toList();
      showingTopPonuda = false;
    });
  }

  void prikaziNajjeftinijuPonudu() {
    if (topPonude.isEmpty) return;
    topPonude.sort((a, b) {
      int cijenaA = int.parse(a['cijena']!.split(' ').first);
      int cijenaB = int.parse(b['cijena']!.split(' ').first);
      return cijenaA.compareTo(cijenaB);
    });
    setState(() {
      filteredPonude = [topPonude.first];
      showingTopPonuda = true;
    });
  }

  void prikaziSvePonude() {
    setState(() {
      filteredPonude = List.from(topPonude);
      showingTopPonuda = false;
    });
  }

  void dodajNekretninu() {
    setState(() {
      Map<String, String> nova = {
        'naziv': 'Nova Nekretnina',
        'cijena': '1000 KM',
        'slika': 'assets/images/default.jpg',
        'spavaceSobe': '2',
        'toalet': '1',
        'grad': 'Novi Grad',
      };
      topPonude.add(nova);
      filteredPonude = List.from(topPonude);
      showingTopPonuda = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Dashboard",
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const SizedBox(height: 40),
              TextField(
                onChanged: (value) => filterPonude(value),
                decoration: InputDecoration(
                  labelText: "Filter po nazivu nekretnine",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: dodajNekretninu,
                    child: Text("Dodaj novu nekretninu"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: prikaziNajjeftinijuPonudu,
                    child: Text("Top ponude"),
                  ),
                  if (showingTopPonuda) ...[
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: prikaziSvePonude,
                      child: Text("Prikazi sve"),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 40),
              Text("Nekretnine",
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: filteredPonude.map((ponuda) {
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              ponuda['slika']!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ponuda['naziv']!,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Cijena: ${ponuda['cijena']}",
                            style: TextStyle(fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bed, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text("${ponuda['spavaceSobe']}",
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 12),
                              Icon(Icons.bathroom,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text("${ponuda['toalet']}",
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 12),
                              Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(ponuda['grad']!,
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Dodaj uređivanje
                                },
                                icon: Icon(Icons.edit, size: 14),
                                label: Text("Uredi",
                                    style: TextStyle(fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  textStyle: TextStyle(fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    topPonude.remove(ponuda);
                                    filteredPonude.remove(ponuda);
                                  });
                                },
                                icon: Icon(Icons.delete, size: 14),
                                label: Text("Obrisi",
                                    style: TextStyle(fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  textStyle: TextStyle(fontSize: 13),
                                ),
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
      ),
    );
  }
}
