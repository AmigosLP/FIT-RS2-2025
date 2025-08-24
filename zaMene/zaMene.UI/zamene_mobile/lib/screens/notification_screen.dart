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
  List<NotificationModel> _notifications = [];
  bool _loading = true;
  String? _error;

  int? _extractUserIdFromToken() {
    final token = AuthProvider.token;
    if (token == null || token.isEmpty) return null;

    final decodedToken = JwtDecoder.decode(token);
    final userIdString = decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
        decodedToken['nameid'];
    if (userIdString == null) return null;

    return int.tryParse(userIdString.toString());
  }

  Future<void> _loadNotifications() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final userId = _extractUserIdFromToken();
    if (userId == null) throw Exception("Korisnik nije autentificiran");

    final notifications = await NotificationService().getNotifications();

    final userNotifications = notifications
        .where((n) => n.userId == userId && (n.isRead ?? false) == false)
        .toList();

    final unreadCount = userNotifications.length;
    Provider.of<NotificationProvider>(context, listen: false)
        .setUnreadCount(unreadCount);

    setState(() {
      _notifications = userNotifications;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
    });
  } finally {
    setState(() {
      _loading = false;
    });
  }
}


  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> markAsRead(int id) async {
    final success = await NotificationService().markAsRead(id);
    if (success) {
      Provider.of<NotificationProvider>(context, listen: false).decrementUnreadCount();

      setState(() {
        _notifications.removeWhere((n) => n.id == id);
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
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Notifikacije")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Notifikacije")),
        body: Center(child: Text("Greška: $_error")),
      );
    }

    if (_notifications.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Notifikacije")),
        body: Center(child: Text("Nemate notifikacija.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikacije"),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(n.title ?? '',
                  style: TextStyle(fontWeight: (n.isRead ?? false) ? FontWeight.normal : FontWeight.bold)),
              subtitle: Text(n.message ?? ''),
              trailing: (n.isRead ?? false)
                  ? const Icon(Icons.done, color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.mark_email_read, color: Colors.blue),
                      tooltip: 'Označi kao pročitano',
                      onPressed: n.id == null ? null : () async => await markAsRead(n.id!),
                    ),
            ),
          );
        },
      ),
    );
  }
}
