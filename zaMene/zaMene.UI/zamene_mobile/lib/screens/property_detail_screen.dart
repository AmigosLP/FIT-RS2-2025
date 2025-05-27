import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:zamene_mobile/screens/image_gallery_screen.dart';
import 'package:zamene_mobile/screens/payment_screen.dart';
import 'package:zamene_mobile/screens/review_screen.dart';
import 'package:zamene_mobile/services/property_service.dart'; // dodaj ovu liniju

class PropertyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> nekretnina;

  const PropertyDetailScreen({super.key, required this.nekretnina});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  double? averageRating;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("initState called");
    loadAverageRating();
    print(widget.nekretnina['imagesUrls']);
  }

  Future<void> loadAverageRating() async {
    try {
      final rating = await PropertyService().getAveragePropertyRating(
        widget.nekretnina['propertyID'],
      );
      setState(() {
        averageRating = rating;
        isLoading = false;
      });
    } catch (e) {
      print('Greška kod ocjene: $e');
      setState(() {
        averageRating = 0.0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final nekretnina = widget.nekretnina;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),
         ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: GestureDetector(
    onTap: () {
      List<String> slike = [];
      // Uzmi listu slika ako postoji, ako imagesUrls, samo glavna slika
      if (widget.nekretnina.containsKey('imagesUrls')) {
        slike = List<String>.from(widget.nekretnina['imagesUrls']);
      
      }

      if (slike.isEmpty && widget.nekretnina['imagesUrls'] != null) {
        slike = [widget.nekretnina['imagesUrls']];
      } 
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageGalleryScreen(
            images: slike,
            initialIndex: 0
          ),
        ),
      );
    },
    child: Image.network(
       (widget.nekretnina.containsKey('imagesUrls') && widget.nekretnina['imagesUrls'].isNotEmpty) 
        ? widget.nekretnina['imagesUrls'][0] 
        : widget.nekretnina['imagesUrls'],
        height: 200,
        width: double.infinity,
      fit: BoxFit.cover,
    ),
  ),
),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nekretnina['naziv'] ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  nekretnina['cijena'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    nekretnina['city'] ?? 'Nepoznat grad',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Row(
                children: [
                  RatingBarIndicator(
                    rating: averageRating ?? 0,
                    itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 20.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (averageRating ?? 0).toStringAsFixed(1),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage("assets/images/user.png"),
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Karlo Ivić", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text("Vlasnik nekretnine", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.message_outlined),
                    color: Colors.blue,
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text("Pogledajte mapu", style: TextStyle(fontSize: 13, color: Colors.grey)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Cijena", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReviewScreen()),
                    );
                  },
                  child: const Text("Detalji", style: TextStyle(fontSize: 13, color: Colors.blue)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("58 BAM  noć / max 4 noći",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text("Stan je isključivo za jednokratno rentanje",
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(nekretnina: nekretnina),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_checkout_rounded),
                label: const Text("Rentaj"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
