// lib/screens/profile_screen.dart

import 'dart:io';
import 'package:chronictech/screens/app_theme_screen.dart';
import 'package:chronictech/screens/edit_profile_screen.dart'; // Import the new screen
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
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String? _profileImageUrl;
  String _displayName = "User Name";
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
        _displayName = userDoc.data()?['name'] ?? 'User Name';
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

  Future<void> _changePassword() async {
    final email = _currentUser?.email;
    if (email == null) {
      _showFeedback(isError: true, message: "Could not find user's email.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showFeedback(
        message: "A password reset link has been sent to your email.",
      );
    } on FirebaseAuthException catch (e) {
      _showFeedback(
        isError: true,
        message: "Failed to send email: ${e.message}",
      );
    }
  }

  // --- Navigates to Edit Profile screen and waits for a result ---
  Future<void> _navigateToEditProfile() async {
    final newName = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(currentName: _displayName),
      ),
    );

    // If the user saved a new name, update the state to show it immediately
    if (newName != null && newName.isNotEmpty) {
      setState(() {
        _displayName = newName;
      });
    }
  }

  // Helper function to show feedback
  void _showFeedback({required String message, bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- UI BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    String displayEmail = _currentUser?.email ?? 'user@example.com';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                    // --- PROFILE HEADER ---
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
                      _displayName,
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

                    // --- ACTION BUTTONS ---
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _navigateToEditProfile, // Connects to the new function
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _changePassword,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Change Password',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- SETTINGS SECTION ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Settings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSettingsTile(title: 'Notifications'),
                    const Divider(height: 1, indent: 16),
                    _buildSettingsTile(
                      title: 'App Theme',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AppThemeScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 16),
                    _buildSettingsTile(title: 'Privacy'),
                    const Divider(height: 1, indent: 16),
                    _buildSettingsTile(title: 'Connected Devices'),
                    const SizedBox(height: 32),

                    // --- LOGOUT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.red.withOpacity(0.1),
                          foregroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper widget for a consistent look in the settings list
  Widget _buildSettingsTile({required String title, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
