import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:zamene_mobile/models/reviews_create_model.dart';
import 'package:zamene_mobile/models/reviews_model.dart';
import 'package:zamene_mobile/screens/image_gallery_screen.dart';
import 'package:zamene_mobile/screens/payment_screen.dart';
import 'package:zamene_mobile/services/reviews_service.dart';
import 'package:zamene_mobile/services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

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

  static const String backendBaseUrl = 'http://10.0.2.2:5283';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  String getFullImageUrl(String path) {
    if (path.startsWith('http')) {
      return path;
    }
    return backendBaseUrl + path;
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
        const SnackBar(content: Text("Recenzija uspješno poslana!")),
      );

      setState(() {
        userRating = 0;
        _commentController.clear();
      });

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
    final primaryColor = Theme.of(context).colorScheme.primary;

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
                  if (widget.nekretnina.containsKey('imageUrls')) {
                    slike = List<String>.from(widget.nekretnina['imageUrls'])
                        .map((path) => getFullImageUrl(path))
                        .toList();
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
                  imageUrl: (widget.nekretnina.containsKey('imageUrls') &&
                          widget.nekretnina['imageUrls'].isNotEmpty)
                      ? getFullImageUrl(widget.nekretnina['imageUrls'][0])
                      : '',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nekretnina['title'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Text(
                  "${(nekretnina['price'] != null ? (nekretnina['price'] as num).toDouble().toStringAsFixed(2) : '0.00')} BAM",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                )
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
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 20, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    nekretnina['agentFullName'] ?? 'Nepoznat vlasnik',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.phone_outlined, color: primaryColor),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Kontakt telefon:"),
                            const SizedBox(height: 8),
                            Text(
                              nekretnina['agentPhoneNumber'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: [
                          TextButton(
                            child: const Text("Zatvori"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.phone, color: Colors.white),
                            label: const Text(
                              "Pozovi",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final Uri phoneUri = Uri(
                                scheme: 'tel',
                                path: nekretnina['agentPhoneNumber'],
                              );
                              Navigator.pop(context);
                              await launchUrl(phoneUri);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text("Opis",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor)),
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
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
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
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text("Recenzije",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor)),
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
                              ? NetworkImage(getFullImageUrl(review.userProfileImageUrl!))
                              : const AssetImage("assets/images/user.png")
                                  as ImageProvider,
                        ),
                        title: Text(
                          review.userFullName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
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
                              style:
                                  const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (reviews.length > 2)
                    ListTile(
                      title: Text(
                        "Prikaži više recenzija...",
                        style: TextStyle(color: primaryColor, fontSize: 13),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => Container(
                            padding: const EdgeInsets.all(16),
                            height: MediaQuery.of(context).size.height * 0.75,
                            child: Column(
                              children: [
                                Text(
                                  "Sve recenzije",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor),
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
                                          backgroundImage: review.userProfileImageUrl !=
                                                  null
                                              ? NetworkImage(
                                                  getFullImageUrl(
                                                      review.userProfileImageUrl!))
                                              : const AssetImage(
                                                      "assets/images/user.png")
                                                  as ImageProvider,
                                        ),
                                        title: Text(
                                          review.userFullName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            RatingBarIndicator(
                                              rating: review.rating.toDouble(),
                                              itemBuilder: (context, _) => const Icon(
                                                  Icons.star,
                                                  color: Colors.amber),
                                              itemCount: 5,
                                              itemSize: 16,
                                              direction: Axis.horizontal,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(review.comment),
                                            Text(
                                              "${review.reviewDate.day.toString().padLeft(2, '0')}.${review.reviewDate.month.toString().padLeft(2, '0')}.${review.reviewDate.year}",
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey),
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
            Text("Ostavi svoju recenziju",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor)),
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
              maxLines: 2,
              minLines: 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                hintText: 'Unesite komentar...',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _submitReview,
                      icon: const Icon(Icons.rate_review, color: Colors.white),
                      label: const Text(
                        "Pošalji recenziju",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
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
                            builder: (_) =>
                                PaymentScreen(nekretnina: widget.nekretnina),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_checkout_rounded,
                          color: Colors.white),
                      label: const Text(
                        "Rentaj",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
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
