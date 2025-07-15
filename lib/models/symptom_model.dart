// lib/models/symptom_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Symptom {
  final String? id;
  final String name;
  final int intensity;
  final String notes;
  final Timestamp timestamp;

  Symptom({
    this.id,
    required this.name,
    required this.intensity,
    required this.notes,
    required this.timestamp,
  });

  // Data ko Firestore mein bhejne ke liye JSON format mein convert karna
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'intensity': intensity,
      'notes': notes,
      'timestamp': timestamp,
    };
  }

  // Firestore se data haasil karne ke liye JSON se object banan
  factory Symptom.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Symptom(
      id: doc.id,
      name: data['name'],
      intensity: data['intensity'],
      notes: data['notes'],
      timestamp: data['timestamp'],
    );
  }
}
