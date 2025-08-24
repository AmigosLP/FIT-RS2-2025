import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import 'package:zamene_mobile/models/property_model.dart';
import 'package:zamene_mobile/models/reviews_create_model.dart';
import 'package:zamene_mobile/models/reviews_model.dart';
import 'package:zamene_mobile/screens/image_gallery_screen.dart';
import 'package:zamene_mobile/screens/payment_screen.dart';
import 'package:zamene_mobile/services/reviews_service.dart';
import 'package:zamene_mobile/services/user_service.dart';

class PropertyDetailScreen extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailScreen({
    super.key,
    required this.property,
  });

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

  bool _didChange = false;

  static const String backendBaseUrl = 'http://10.0.2.2:5283';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String getFullImageUrl(String path) {
    if (path.startsWith('http')) return path;
    final normalized = path.replaceAll(r'\', '/');
    return normalized.startsWith('/') ? (backendBaseUrl + normalized) : ('$backendBaseUrl/$normalized');
  }

  Future<void> _loadReviews() async {
    setState(() => isLoadingReviews = true);
    try {
      final service = ReviewService();
      final id = widget.property.propertyID;
      if (id != null) {
        final fetchedReviews = await service.getReviewsByPropertyId(id);
        setState(() {
          reviews = fetchedReviews;
          isLoadingReviews = false;
        });
      } else {
        setState(() => isLoadingReviews = false);
      }
    } catch (_) {
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
      final propertyID = widget.property.propertyID;
      if (propertyID == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nedostaje ID nekretnine.")),
        );
        return;
      }

      final review = ReviewCreateModel(
        userID: userID,
        propertyID: propertyID,
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
        _didChange = true;
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
    final p = widget.property;
    final String opis = p.description ?? 'Nema opisa...';
    final primaryColor = Theme.of(context).colorScheme.primary;

    final List<String> images = (p.imageUrls ?? [])
        .where((u) => (u != null && u.toString().trim().isNotEmpty))
        .map((u) => getFullImageUrl(u))
        .toList();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _didChange);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context, _didChange),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: () {
                final title = p.title ?? "Nekretnina";
                final city = p.city ?? "Nepoznat grad";
                final price = (p.price ?? 0).toStringAsFixed(2);
                
                final shareText = "🏠 $title\n📍 $city\n💰 $price BAM";
                Share.share(shareText, subject: "Pogledaj ovu nekretninu");
              },
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
                    if (images.isEmpty) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImageGalleryScreen(
                          images: images,
                          initialIndex: 0,
                        ),
                      ),
                    );
                  },
                  child: images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: images.first,
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
                        )
                      : Image.asset(
                          'assets/images/zaMeneLogo2.png',
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
                  Expanded(
                    child: Text(
                      p.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${(p.price ?? 0).toStringAsFixed(2)} BAM",
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
                      p.city ?? 'Nepoznat grad',
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
                      p.agentFullName ?? 'Nepoznat vlasnik',
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
                      final phone = p.agentPhoneNumber;
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Kontakt telefon:"),
                              const SizedBox(height: 8),
                              Text(
                                phone ?? 'N/A',
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
                              onPressed: phone == null || phone.isEmpty
                                  ? null
                                  : () async {
                                      final Uri phoneUri = Uri(
                                        scheme: 'tel',
                                        path: phone,
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

              Text(
                "Opis",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 6),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.description ?? 'Nema opisa...',
                      maxLines: showFullDescription ? null : 3,
                      overflow: showFullDescription
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      textAlign: TextAlign.justify,
                    ),
                    if ((p.description ?? '').length > 100)
                      TextButton(
                        onPressed: () =>
                            setState(() => showFullDescription = !showFullDescription),
                        child: Text(
                          showFullDescription ? "Sakrij" : "Prikaži više",
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Recenzije",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
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
                                ? NetworkImage(getFullImageUrl(
                                    review.userProfileImageUrl!))
                                : const AssetImage("assets/images/user.png")
                                    as ImageProvider,
                          ),
                          title: Text(
                            review.userFullName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: primaryColor),
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
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
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
                                            backgroundImage:
                                                review.userProfileImageUrl != null
                                                    ? NetworkImage(getFullImageUrl(
                                                        review
                                                            .userProfileImageUrl!))
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
                                                itemBuilder: (context, _) =>
                                                    const Icon(Icons.star,
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

              Text(
                "Ostavi svoju recenziju",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 10),

              RatingBar.builder(
                initialRating: userRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 30,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  setState(() => userRating = rating);
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
                              builder: (_) => PaymentScreen(
                                nekretnina: widget.property.toJson(),
                              ),
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
      ),
    );
  }
}
