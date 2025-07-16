// lib/main.dart

import 'package:chronictech/providers/theme_provider.dart';
import 'package:chronictech/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
    // Wrap the app with the ThemeProvider
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const ChroniTechApp(),
    ),
  );
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
