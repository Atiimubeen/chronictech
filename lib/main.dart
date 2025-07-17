// lib/main.dart

import 'package:chronictech/providers/theme_provider.dart';
import 'package:chronictech/screens/splash_screen.dart';
import 'package:chronictech/services/notification_service.dart'; // Import the service
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // --- Initialize all services ---
    await NotificationService().init();
    await Firebase.initializeApp();

    // If all initializations are successful, run the main app
    runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const ChroniTechApp(),
      ),
    );
  } catch (e) {
    // --- In case of an initialization error, show an error screen ---
    print("Failed to initialize app: $e");
    runApp(MaterialApp(home: ErrorScreen(error: e.toString())));
  }
}

class ChroniTechApp extends StatelessWidget {
  const ChroniTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to listen for theme changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ChroniTech',

          // Set the theme mode from the provider
          themeMode: themeProvider.themeMode,

          // Define your light theme
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.teal,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black,
            ),
          ),

          // Define your dark theme
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.teal,
            scaffoldBackgroundColor: const Color(0xFF121212),
            // You can customize other properties for the dark theme here
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}

// A simple screen to display initialization errors
class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Failed to start the application. Please restart the app.\n\nError: $error",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
