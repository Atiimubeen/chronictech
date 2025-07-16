// lib/services/insight_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// A new class to hold our insights with a severity level
enum InsightLevel { info, warning, critical }

class HealthInsight {
  final String message;
  final InsightLevel level;

  HealthInsight({required this.message, required this.level});
}

class InsightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  Future<List<HealthInsight>> generateSymptomInsights() async {
    if (_user == null) return [];

    final List<HealthInsight> insights = [];
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    // Fetch all symptoms for more complex analysis
    final snapshot = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('symptoms')
        .orderBy('timestamp', descending: true)
        .get();

    if (snapshot.docs.isEmpty) {
      return [
        HealthInsight(
          message:
              "Log your symptoms to start receiving personalized health insights.",
          level: InsightLevel.info,
        ),
      ];
    }

    final allSymptoms = snapshot.docs.map((doc) => doc.data()).toList();
    final recentSymptoms = allSymptoms
        .where(
          (s) => (s['timestamp'] as Timestamp).toDate().isAfter(sevenDaysAgo),
        )
        .toList();

    // --- Insight 1: High-Intensity Alert (Critical) ---
    final highIntensitySymptoms = recentSymptoms
        .where((s) => (s['intensity'] as int) >= 8)
        .toList();
    if (highIntensitySymptoms.isNotEmpty) {
      final symptomName = highIntensitySymptoms.first['name'];
      insights.add(
        HealthInsight(
          message:
              "You've logged '$symptomName' with a high intensity. If this symptom persists or worsens, we strongly recommend consulting a doctor.",
          level: InsightLevel.critical,
        ),
      );
    }

    // --- Insight 2: Increasing Frequency Trend (Warning) ---
    if (allSymptoms.length > 5) {
      // Only run if there's enough data
      final Map<String, int> recentFrequency = {};
      for (var s in recentSymptoms) {
        recentFrequency[s['name']] = (recentFrequency[s['name']] ?? 0) + 1;
      }

      if (recentFrequency.isNotEmpty) {
        final mostFrequentRecent = recentFrequency.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );
        if (mostFrequentRecent.value > 3) {
          insights.add(
            HealthInsight(
              message:
                  "You've logged '${mostFrequentRecent.key}' frequently this week. Pay attention to any patterns or triggers.",
              level: InsightLevel.warning,
            ),
          );
        }
      }
    }

    // --- Insight 3: General Info ---
    if (insights.isEmpty) {
      insights.add(
        HealthInsight(
          message:
              "Keep logging your symptoms consistently to help us find more meaningful patterns in your health.",
          level: InsightLevel.info,
        ),
      );
    }

    return insights;
  }
}
