import 'package:flutter/material.dart';
import 'package:zamene_desktop/models/review_desktop_model.dart';
import 'package:zamene_desktop/providers/review_desktop_provider.dart';

class RecenzijeScreen extends StatefulWidget {
  const RecenzijeScreen({super.key});

  @override
  State<RecenzijeScreen> createState() => _RecenzijeScreenState();
}

class _RecenzijeScreenState extends State<RecenzijeScreen> {
  List<ReviewDesktopModel> recenzije = [];
  bool isLoading = true;

  final ReviewDesktopService _reviewService = ReviewDesktopService();

  @override
  void initState() {
    super.initState();
    _ucitajRecenzije();
  }

  Future<void> _ucitajRecenzije() async {
    try {
      final result = await _reviewService.fetchAllReviews();
      setState(() {
        recenzije = result;
        isLoading = false;
      });
    } catch (e) {
      print("Greška: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška pri učitavanju recenzija")),
      );
    }
  }

  void obrisiRecenziju(int reviewId) async {
    try {
      await _reviewService.deleteReview(reviewId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recenzija uspješno obrisana")),
      );
      _ucitajRecenzije();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška pri brisanju")),
      );
    }
  }

  void _showFullDescription(String description) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Detaljan opis nekretnine"),
        content: SingleChildScrollView(child: Text(description)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Zatvori"),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(ReviewDesktopModel review) async {
    final commentController = TextEditingController(text: review.comment);
    int currentRating = review.rating;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Uredi recenziju'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ocjena:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < currentRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        currentRating = index + 1;
                      });
                      // Trigger rebuild of dialog content
                      (context as Element).markNeedsBuild();
                    },
                  );
                }),
              ),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Komentar',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedReview = ReviewDesktopModel(
                  reviewID: review.reviewID,
                  rating: currentRating,
                  comment: commentController.text,
                  userFullName: review.userFullName,
                  propertyName: review.propertyName,
                  address: review.address,
                  price: review.price,
                  description: review.description,
                  reviewDate: review.reviewDate,
                );

                bool success = await _reviewService.updateReview(updatedReview);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recenzija uspješno ažurirana')),
                  );
                  Navigator.of(context).pop();
                  _ucitajRecenzije();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Greška prilikom ažuriranja')),
                  );
                }
              },
              child: const Text('Spremi'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    final textWidget = Expanded(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 6),
          onTap != null
              ? GestureDetector(onTap: onTap, child: textWidget)
              : textWidget,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "Administracija recenzija",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            ...recenzije.map((recenzija) {
              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recenzija.userFullName ?? 'Nepoznat vlasnik',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(recenzija.comment ?? 'Nepoznata recenzija'),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < recenzija.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(Icons.home, "Nekretnina", recenzija.propertyName ?? "Nepoznata nekretnina"),
                      _buildInfoRow(Icons.location_on, "Adresa", recenzija.address ?? "Nepoznata adresa"),
                      _buildInfoRow(Icons.attach_money, "Cijena", "${recenzija.price ?? 0} KM"),

                      _buildInfoRow(
                        Icons.description,
                        "Opis",
                        recenzija.description != null
                            ? (recenzija.description!.length > 100
                                ? '${recenzija.description!.substring(0, 100)}... (više)'
                                : recenzija.description!)
                            : "Nema opisa",
                        onTap: recenzija.description != null
                            ? () => _showFullDescription(recenzija.description!)
                            : null,
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => obrisiRecenziju(recenzija.reviewID),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text("Delete", style: TextStyle(color: Colors.red)),
                          ),
                          TextButton.icon(
                            onPressed: () => _showEditDialog(recenzija),
                            icon: const Icon(Icons.edit),
                            label: const Text("Edit"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
