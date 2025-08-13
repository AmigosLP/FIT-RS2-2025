import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zamene_mobile/providers/favorite_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'providers/notification_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()..syncFromServer()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Za Mene Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
