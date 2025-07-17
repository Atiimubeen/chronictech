// lib/screens/auth_gate.dart

import 'package:chronictech/screens/admin/admin_dashboard_screen.dart';
import 'package:chronictech/screens/login_screen.dart';
import 'package:chronictech/screens/main_layout.dart';
import 'package:chronictech/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If user is not logged in, show login screen
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // If user IS logged in, check if they are an admin
        return FutureBuilder<bool>(
          future: AuthService().isAdmin(),
          builder: (context, adminSnapshot) {
            // While checking, show a loading indicator
            if (adminSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // If the user is an admin, show the admin dashboard
            if (adminSnapshot.data == true) {
              return const AdminDashboardScreen();
            }

            // Otherwise, show the regular user layout
            return const MainLayout();
          },
        );
      },
    );
  }
}
