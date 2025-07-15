// lib/screens/symptom_detail_screen.dart

import 'package:chronictech/models/symptom_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SymptomDetailScreen extends StatelessWidget {
  final Symptom symptom;

  const SymptomDetailScreen({super.key, required this.symptom});

  // Function to handle the delete action
  Future<void> _deleteSymptom(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || symptom.id == null) return;

    // Show confirmation dialog
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this symptom log?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User cancels
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User confirms
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
            .collection('symptoms')
            .doc(symptom.id)
            .delete();

        // Go back to the previous screen after deletion
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Show an error message if deletion fails
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete symptom: $e'),
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
        title: Text(symptom.name),
        actions: [
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _deleteSymptom(context),
            tooltip: 'Delete Symptom',
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
              icon: Icons.calendar_today_outlined,
              title: 'Date Logged',
              subtitle: DateFormat.yMMMMd().add_jm().format(
                symptom.timestamp.toDate(),
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailCard(
              context,
              icon: Icons.speed_outlined,
              title: 'Intensity',
              subtitle: '${symptom.intensity} / 10',
            ),
            const SizedBox(height: 12),
            if (symptom.notes.isNotEmpty)
              _buildDetailCard(
                context,
                icon: Icons.notes_outlined,
                title: 'Notes',
                subtitle: symptom.notes,
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
