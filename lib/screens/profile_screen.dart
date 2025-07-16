// lib/screens/profile_screen.dart

import 'dart:io';
import 'package:chronictech/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String? _profileImageUrl;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- DATA HANDLING LOGIC ---

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    if (_currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _nameController.text = userDoc.data()?['name'] ?? '';
        _profileImageUrl = userDoc.data()?['profileImageUrl'];
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickAndUploadImage() async {
    if (_isPickingImage) return;

    try {
      setState(() => _isPickingImage = true);
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile == null) {
        setState(() => _isPickingImage = false);
        return;
      }

      setState(() => _isLoading = true);
      File imageFile = File(pickedFile.path);

      final String? downloadUrl = await StorageService().uploadProfileImage(
        imageFile,
      );

      if (downloadUrl != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .set({'profileImageUrl': downloadUrl}, SetOptions(merge: true));
        setState(() => _profileImageUrl = downloadUrl);
        _showFeedback(message: "Profile picture updated!");
      }
    } catch (e) {
      _showFeedback(isError: true, message: "Failed to upload image.");
    } finally {
      setState(() {
        _isLoading = false;
        _isPickingImage = false;
      });
    }
  }

  // --- CHANGE: This function now saves BOTH name and email ---
  Future<void> _saveProfileChanges() async {
    if (_nameController.text.trim().isEmpty) {
      _showFeedback(isError: true, message: "Name cannot be empty.");
      return;
    }
    if (_currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({
            'name': _nameController.text.trim(),
            'email':
                _currentUser!.email, // This will add/update the email field
          }, SetOptions(merge: true));
      _showFeedback(message: "Profile updated successfully!");
    } catch (e) {
      _showFeedback(isError: true, message: "Failed to update profile.");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _changePassword() async {
    // ... (code remains the same)
  }

  void _showFeedback({required String message, bool isError = false}) {
    // ... (code remains the same)
  }

  // --- UI BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    String displayName = _nameController.text.isNotEmpty
        ? _nameController.text
        : "User Name";

    String displayEmail = _currentUser?.email ?? 'user@example.com';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 10.0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _profileImageUrl == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey.shade400,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayEmail,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- EDIT PROFILE SECTION ---
                    Card(
                      elevation: 0,
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Edit Your Details",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: "Full Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _saveProfileChanges,
                                child: const Text("Save Changes"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- SECURITY & LOGOUT ---
                    _buildSettingsTile(
                      title: 'Change Password',
                      onTap: _changePassword,
                    ),
                    const Divider(height: 1, indent: 16),
                    _buildSettingsTile(
                      title: 'Logout',
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () => FirebaseAuth.instance.signOut(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16, color: textColor)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: textColor ?? Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
