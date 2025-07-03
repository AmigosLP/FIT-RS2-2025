import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:zamene_mobile/models/notification_model.dart';
import 'package:zamene_mobile/services/notification_service.dart';
import 'package:zamene_mobile/providers/auth_provide.dart';
import 'package:zamene_mobile/providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationModel>> _notificationsFuture;

  int? _extractUserIdFromToken() {
    final token = AuthProvider.token;
    if (token == null || token.isEmpty) return null;

    final decodedToken = JwtDecoder.decode(token);
    final userIdString = decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
        decodedToken['nameid'];
    if (userIdString == null) return null;

    return int.tryParse(userIdString.toString());
  }

  Future<List<NotificationModel>> _loadNotifications() async {
    final userId = _extractUserIdFromToken();
    if (userId == null) throw Exception("Korisnik nije autentificiran");

    final notifications = await NotificationService().getNotifications();

    final userNotifications = notifications.where((n) => n.userId == userId).toList();

    final unreadCount = userNotifications.where((n) => n.isRead == false).length;
    Provider.of<NotificationProvider>(context, listen: false).setUnreadCount(unreadCount);

    return userNotifications;
  }

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _loadNotifications();
  }

  Future<void> markAsRead(int id) async {
    final success = await NotificationService().markAsRead(id);
    if (success) {
      Provider.of<NotificationProvider>(context, listen: false).decrementUnreadCount();

      setState(() {
        _notificationsFuture = _loadNotifications();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifikacija označena kao pročitana'), behavior: SnackBarBehavior.floating),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Neuspjelo označavanje kao pročitano'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikacije"),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Greška: ${snapshot.error}"));
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text("Nemate notifikacija."));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(n.title ?? '', style: TextStyle(fontWeight: (n.isRead ?? false) ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(n.message ?? ''),
                  trailing: (n.isRead ?? false)
                      ? const Icon(Icons.done, color: Colors.green)
                      : IconButton(
                          icon: const Icon(Icons.mark_email_read, color: Colors.blue),
                          tooltip: 'Označi kao pročitano',
                          onPressed: () async => markAsRead(n.notificationID!),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
