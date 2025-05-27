import 'package:flutter/material.dart';
import 'package:zamene_desktop/layouts/master_screen.dart';

class RecenzijeScreen extends StatefulWidget {
  const RecenzijeScreen({super.key});

  @override
  _RecenzijeScreenState createState() => _RecenzijeScreenState();
}

class _RecenzijeScreenState extends State<RecenzijeScreen> {
  List<Map<String, dynamic>> recenzije = [
    {
      'korisnik': 'Berun Agić',
      'tekst': 'Odličan stan, vlasnik je ispoštovao dogovor vezano za peškire!',
      'stan': 'Tuzla – trg',
      'zvjezdice': 4
    },
    {
      'korisnik': 'Adil Hrijić',
      'tekst': 'Odlično sve!',
      'stan': 'Brčanska malta',
      'zvjezdice': 5
    },
    {
      'korisnik': 'Brankica Ivić',
      'tekst': 'Ne sviđa mi se!',
      'stan': '60 KM sa režije',
      'zvjezdice': 1
    },
  ];

  void obrisiRecenziju(int index) {
    setState(() {
      recenzije.removeAt(index);
    });
  }

  void urediRecenziju(int index) {
    // Dodaj logiku za uređivanje (npr. otvori formu s postojećim podacima)
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Recenzije",
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: recenzije.map((recenzija) {
            int index = recenzije.indexOf(recenzija);
            return Card(
              margin: EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${recenzija['korisnik']} - ${recenzija['stan']}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text(recenzija['tekst']),
                    SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < recenzija['zvjezdice']
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => obrisiRecenziju(index),
                          icon: Icon(Icons.delete, color: Colors.red),
                          label: Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                        TextButton.icon(
                          onPressed: () => urediRecenziju(index),
                          icon: Icon(Icons.edit),
                          label: Text("Edit"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
