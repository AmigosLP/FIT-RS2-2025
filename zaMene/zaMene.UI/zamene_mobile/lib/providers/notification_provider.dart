import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:zamene_mobile/providers/auth_provide.dart';
import 'package:zamene_mobile/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void setUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  void incrementUnreadCount() {
    _unreadCount++;
    notifyListeners();
  }

  void decrementUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
  try {
    final token = AuthProvider.token;
    if (token == null) return;
    final decoded = JwtDecoder.decode(token);
    final userIdStr = decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ?? decoded['nameid'];
    final userId = int.tryParse(userIdStr.toString()) ?? 0;
    final count = await NotificationService().getUnreadNotificationCount(userId);
    setUnreadCount(count);
  } catch (e) {
    print("Greška pri dohvaćanju unread count: $e");
  }
}
  
}
