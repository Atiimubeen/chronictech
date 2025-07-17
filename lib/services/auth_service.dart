// lib/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if the current user is an admin
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data()!.containsKey('isAdmin')) {
        // Return true only if the isAdmin field is explicitly true
        return userDoc.data()!['isAdmin'] as bool;
      }
      // Return false if the document or field doesn't exist
      return false;
    } catch (e) {
      print("Error checking admin status: $e");
      return false;
    }
  }
}
