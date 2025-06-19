import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:zamene_mobile/models/reviews_create_model.dart';
import 'package:zamene_mobile/models/reviews_model.dart';
import 'package:zamene_mobile/screens/image_gallery_screen.dart';
import 'package:zamene_mobile/screens/payment_screen.dart';
import 'package:zamene_mobile/services/reviews_service.dart';
import 'package:zamene_mobile/providers/auth_provide.dart';
import 'package:zamene_mobile/services/user_service.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> nekretnina;

  const PropertyDetailScreen({super.key, required this.nekretnina});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen>
    with TickerProviderStateMixin {
  bool showFullDescription = false;
  double userRating = 0;
  final TextEditingController _commentController = TextEditingController();

  List<ReviewModel> reviews = [];
  bool isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => isLoadingReviews = true);
    try {
      final service = ReviewService();
      final fetchedReviews =
          await service.getReviewsByPropertyId(widget.nekretnina['propertyID']);
      setState(() {
        reviews = fetchedReviews;
        isLoadingReviews = false;
      });
    } catch (e) {
      setState(() => isLoadingReviews = false);
      // Možeš ovdje prikazati grešku ako želiš
    }
  }

  Future<void> _submitReview() async {
    if (userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Molimo odaberite ocjenu.")),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Molimo unesite komentar.")),
      );
      return;
    }

    try {
      // Dohvati userID iz tokena
      final userID = await UserService().getUserIdFromToken();

      final review = ReviewCreateModel(
        userID: userID,
        propertyID: widget.nekretnina['propertyID'],
        rating: userRating.toInt(),
        comment: _commentController.text.trim(),
      );

      final service = ReviewService();
      await service.createReview(review);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recenzija uspješno poslata!")),
      );

      setState(() {
        userRating = 0;
        _commentController.clear();
      });

      // Ponovno učitaj recenzije da prikažeš novu recenziju
      await _loadReviews();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri slanju recenzije: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nekretnina = widget.nekretnina;
    final String opis = nekretnina['description'] ?? 'Nema opisa...';

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
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GestureDetector(
                onTap: () {
                  List<String> slike = [];
                  if (widget.nekretnina.containsKey('imagesUrls')) {
                    slike = List<String>.from(widget.nekretnina['imagesUrls']);
                  }
                  if (slike.isEmpty && widget.nekretnina['imagesUrls'] != null) {
                    slike = [widget.nekretnina['imagesUrls']];
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ImageGalleryScreen(images: slike, initialIndex: 0),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: (widget.nekretnina.containsKey('imagesUrls') &&
                          widget.nekretnina['imagesUrls'].isNotEmpty)
                      ? widget.nekretnina['imagesUrls'][0]
                      : widget.nekretnina['imagesUrls'] ?? '',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nekretnina['naziv'] ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  nekretnina['cijena'] ?? '',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
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
                    nekretnina['grad'] ?? 'Nepoznat grad',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
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
                      Text("Karlo Ivić",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text("Vlasnik nekretnine",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
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
            const Text("Opis",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opis,
                    maxLines: showFullDescription ? null : 3,
                    overflow: showFullDescription
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.justify,
                  ),
                  if (opis.length > 100)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showFullDescription = !showFullDescription;
                        });
                      },
                      child: Text(
                        showFullDescription ? "Sakrij" : "Prikaži više",
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- Dinamičke recenzije ---
            const Text("Recenzije",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (isLoadingReviews)
              const Center(child: CircularProgressIndicator())
            else if (reviews.isEmpty)
              const Text("Nema recenzija za ovu nekretninu.")
            else
              Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length > 2 ? 2 : reviews.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: review.userProfileImageUrl != null
                              ? NetworkImage(
                                  'http://10.0.2.2:5283${review.userProfileImageUrl}')
                              : const AssetImage("assets/images/user.png")
                                  as ImageProvider,
                        ),
                        title: Text(
                          review.userFullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            RatingBarIndicator(
                              rating: review.rating.toDouble(),
                              itemBuilder: (context, _) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 16,
                              direction: Axis.horizontal,
                            ),
                            const SizedBox(height: 4),
                            Text(review.comment),
                            Text(
                              "${review.reviewDate.day.toString().padLeft(2, '0')}.${review.reviewDate.month.toString().padLeft(2, '0')}.${review.reviewDate.year}",
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (reviews.length > 2)
                    ListTile(
                      title: const Text(
                        "Prikaži više recenzija...",
                        style: TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                      trailing: const Icon(Icons.more_horiz, color: Colors.blue),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => Container(
                            padding: const EdgeInsets.all(16),
                            height: MediaQuery.of(context).size.height * 0.75,
                            child: Column(
                              children: [
                                const Text(
                                  "Sve recenzije",
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: reviews.length,
                                    separatorBuilder: (_, __) => const Divider(),
                                    itemBuilder: (context, index) {
                                      final review = reviews[index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: review.userProfileImageUrl != null
                                              ? NetworkImage(
                                                  'http://10.0.2.2:5283${review.userProfileImageUrl}')
                                              : const AssetImage(
                                                      "assets/images/user.png")
                                                  as ImageProvider,
                                        ),
                                        title: Text(
                                          review.userFullName,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            RatingBarIndicator(
                                              rating: review.rating.toDouble(),
                                              itemBuilder: (context, _) =>
                                                  const Icon(Icons.star, color: Colors.amber),
                                              itemCount: 5,
                                              itemSize: 16,
                                              direction: Axis.horizontal,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(review.comment),
                                            Text(
                                              "${review.reviewDate.day.toString().padLeft(2, '0')}.${review.reviewDate.month.toString().padLeft(2, '0')}.${review.reviewDate.year}",
                                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),

            const SizedBox(height: 10),
            const Text("Ostavi svoju recenziju",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            RatingBar.builder(
              initialRating: userRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  userRating = rating;
                });
              },
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Unesite komentar...',
              ),
            ),

            const SizedBox(height: 20),

            // Dugmad "Pošalji recenziju" i "Rentaj" u redu, iste veličine
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _submitReview,
                      icon: const Icon(Icons.rate_review),
                      label: const Text(
                        "Pošalji recenziju",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(nekretnina: widget.nekretnina),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_checkout_rounded),
                      label: const Text(
                        "Rentaj",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
