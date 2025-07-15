// lib/screens/medicine_detail_screen.dart

import 'package:chronictech/models/medicine_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MedicineDetailScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailScreen({super.key, required this.medicine});

  // Function to handle the delete action
  Future<void> _deleteMedicine(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || medicine.id == null) return;

    // Show confirmation dialog
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this medicine?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // If user confirmed, proceed with deletion
    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('medicines')
            .doc(medicine.id)
            .delete();

        // Go back to the previous screen after deletion
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete medicine: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
        actions: [
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _deleteMedicine(context),
            tooltip: 'Delete Medicine',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              context,
              icon: Icons.medication,
              title: 'Medicine Name',
              subtitle: medicine.name,
            ),
            const SizedBox(height: 12),
            _buildDetailCard(
              context,
              icon: Icons.science_outlined,
              title: 'Dosage',
              subtitle: medicine.dosage,
            ),
            const SizedBox(height: 12),
            _buildDetailCard(
              context,
              icon: Icons.watch_later_outlined,
              title: 'Frequency',
              subtitle: medicine.frequency,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build consistent detail cards
  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
