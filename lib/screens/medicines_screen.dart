// lib/screens/medicines_screen.dart

import 'package:chronictech/models/medicine_model.dart';
import 'package:chronictech/screens/add_medicine_screen.dart';
import 'package:chronictech/screens/medicine_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Enum to define the sorting options
enum SortOptions { byDate, byName }

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  // State variable to hold the current sorting option
  SortOptions _currentSortOption = SortOptions.byDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Medicines',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // --- CHANGE: Leading menu icon removed ---
        automaticallyImplyLeading: false,
        actions: [
          // --- CHANGE: Sorting menu added ---
          PopupMenuButton<SortOptions>(
            icon: const Icon(Icons.sort),
            onSelected: (SortOptions result) {
              setState(() {
                _currentSortOption = result;
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<SortOptions>>[
                  const PopupMenuItem<SortOptions>(
                    value: SortOptions.byDate,
                    child: Text('Sort by Date Added'),
                  ),
                  const PopupMenuItem<SortOptions>(
                    value: SortOptions.byName,
                    child: Text('Sort by Name (A-Z)'),
                  ),
                ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // --- CHANGE: The query now dynamically changes based on the sort option ---
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .collection('medicines')
            .orderBy(
              _currentSortOption == SortOptions.byDate ? 'timestamp' : 'name',
              descending: _currentSortOption == SortOptions.byDate,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No medicines added yet.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final medicines = snapshot.data!.docs
              .map((doc) => Medicine.fromJson(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medication_outlined,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
                title: Text(
                  medicine.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '${medicine.dosage} | ${medicine.frequency}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.notifications_none_outlined),
                  onPressed: () {
                    // TODO: Implement reminder on/off functionality
                  },
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          MedicineDetailScreen(medicine: medicine),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
          );
        },
        label: const Text(
          'Add Medicine',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
