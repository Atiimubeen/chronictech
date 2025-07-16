// lib/screens/admin/user_detail_view_screen.dart

import 'package:chronictech/models/medicine_model.dart';
import 'package:chronictech/models/symptom_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserDetailViewScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const UserDetailViewScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Symptoms and Medicines
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          title: Text(
            userName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: const [
              Tab(text: 'Symptoms'),
              Tab(text: 'Medicines'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- SYMPTOMS TAB ---
            _buildSymptomList(context),
            // --- MEDICINES TAB ---
            _buildMedicineList(context),
          ],
        ),
      ),
    );
  }

  // Widget to build the list of symptoms for the user
  Widget _buildSymptomList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('symptoms')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No symptoms logged by this user.'));
        }

        final symptoms = snapshot.data!.docs
            .map((doc) => Symptom.fromJson(doc))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: symptoms.length,
          itemBuilder: (context, index) {
            final symptom = symptoms[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              title: Text(
                symptom.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                DateFormat(
                  'MMMM d, yyyy, hh:mm a',
                ).format(symptom.timestamp.toDate()),
                style: TextStyle(color: Colors.grey.shade600),
              ),
              trailing: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    symptom.intensity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget to build the list of medicines for the user
  Widget _buildMedicineList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medicines')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No medicines added by this user.'));
        }

        final medicines = snapshot.data!.docs
            .map((doc) => Medicine.fromJson(doc))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
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
            );
          },
        );
      },
    );
  }
}
