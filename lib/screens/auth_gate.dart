// lib/screens/auth_gate.dart

import 'package:chronictech/screens/login_screen.dart';
import 'package:chronictech/screens/main_layout.dart';
// Is line ko import karein
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // HomeScreen() ke bajaye MainLayout() return karein
        return const MainLayout();
      },
    );
  }
}
