// lib/screens/medicines_screen.dart

import 'package:chronictech/models/medicine_model.dart';
import 'package:chronictech/screens/add_medicine_screen.dart';
import 'package:chronictech/screens/medicine_detail_screen.dart'; // Import the new screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Medications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .collection('medicines')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No medicines added yet.\nPress the + button to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            );
          }

          final medicines = snapshot.data!.docs
              .map((doc) => Medicine.fromJson(doc))
              .toList();

          return ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2F1), // Light Teal
                    child: Icon(Icons.medication_outlined, color: Colors.teal),
                  ),
                  title: Text(
                    medicine.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${medicine.dosage} - ${medicine.frequency}'),
                  trailing: const Icon(Icons.chevron_right),
                  // --- THIS IS THE UPDATED PART ---
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            MedicineDetailScreen(medicine: medicine),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
          );
        },
        tooltip: 'Add Medicine',
        child: const Icon(Icons.add),
      ),
    );
  }
}
