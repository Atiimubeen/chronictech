// lib/main.dart

import 'package:chronictech/screens/splash_screen.dart';
import 'package:chronictech/services/notification_service.dart'; // Import the service
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notification Service
  await NotificationService().init();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const ChroniTechApp());
}

class ChroniTechApp extends StatelessWidget {
  const ChroniTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChroniTech',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const SplashScreen(),
    );
  }
}
