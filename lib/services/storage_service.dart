// lib/services/storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  Future<String?> uploadProfileImage(File imageFile) async {
    if (_user == null) return null;

    try {
      final ref = _storage
          .ref()
          .child('profile_pictures')
          .child(_user!.uid + '.jpg');

      // --- ADD THIS PRINT STATEMENT ---
      print("DEBUG: Uploading to path: ${ref.fullPath}");

      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
}
