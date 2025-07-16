// lib/screens/admin/user_detail_view_screen.dart

import 'package:flutter/material.dart';

class UserDetailViewScreen extends StatelessWidget {
  final String userId; // We will pass the user's ID to this screen

  const UserDetailViewScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch and display this user's symptoms and medicines
    return Scaffold(
      appBar: AppBar(title: const Text("User's Health Data")),
      body: Center(child: Text("Details for user: $userId")),
    );
  }
}
