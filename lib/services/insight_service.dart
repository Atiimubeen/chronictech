// lib/services/insight_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InsightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  Future<List<String>> generateSymptomInsights() async {
    if (_user == null) return [];

    final List<String> insights = [];
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    final snapshot = await _firestore
        .collection('users')
        .doc(_user.uid)
        .collection('symptoms')
        .get();

    if (snapshot.docs.isEmpty) {
      return ["Log your first symptom to start generating insights."];
    }

    // Insight 1: Check for any high-intensity symptoms in the last week
    final recentDocs = snapshot.docs.where((doc) {
      final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
      return timestamp.isAfter(sevenDaysAgo);
    }).toList();

    bool hasHighIntensitySymptom = recentDocs.any(
      (doc) => (doc.data()['intensity'] as int) >= 8,
    );
    if (hasHighIntensitySymptom) {
      insights.add(
        "You've logged a high-intensity symptom this week. Keep an eye on it and consider consulting a doctor if it persists.",
      );
    }

    // Insight 2: Find the most frequently logged symptom overall
    final Map<String, int> frequencyMap = {};
    for (var doc in snapshot.docs) {
      final symptomName = doc.data()['name'] as String;
      frequencyMap[symptomName] = (frequencyMap[symptomName] ?? 0) + 1;
    }

    if (frequencyMap.isNotEmpty) {
      final mostFrequentSymptom = frequencyMap.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );

      // --- LOGIC CHANGED HERE ---
      // Now it will show an insight even for one entry.
      insights.add(
        'Your most commonly logged symptom is "${mostFrequentSymptom.key}".',
      );
    }

    if (insights.isEmpty) {
      insights.add(
        "Keep logging your symptoms consistently to generate more insights.",
      );
    }

    return insights;
  }
}
