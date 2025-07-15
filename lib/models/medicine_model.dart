// lib/models/medicine_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String? id;
  final String name;
  final String dosage; // e.g., "500mg", "1 tablet"
  final String frequency; // e.g., "Twice a day"

  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'timestamp': FieldValue.serverTimestamp(), // To know when it was added
    };
  }

  factory Medicine.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Medicine(
      id: doc.id,
      name: data['name'],
      dosage: data['dosage'],
      frequency: data['frequency'],
    );
  }
}
