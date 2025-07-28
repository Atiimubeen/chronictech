// lib/services/admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// --- THIS CLASS DEFINITION IS REQUIRED BY THE DASHBOARD ---
class DashboardStats {
  final int totalUsers;
  final int symptomsLoggedToday;
  final int activeChats;

  DashboardStats({
    required this.totalUsers,
    required this.symptomsLoggedToday,
    required this.activeChats,
  });
}

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DashboardStats> getDashboardStats() async {
    // 1. Get total users
    final usersSnapshot = await _firestore.collection('users').get();
    final totalUsers = usersSnapshot.docs.length;

    // 2. Get symptoms logged in the last 24 hours
    int symptomsToday = 0;
    final twentyFourHoursAgo = DateTime.now().subtract(
      const Duration(hours: 24),
    );
    for (var userDoc in usersSnapshot.docs) {
      final symptomsSnapshot = await _firestore
          .collection('users')
          .doc(userDoc.id)
          .collection('symptoms')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(twentyFourHoursAgo),
          )
          .get();
      symptomsToday += symptomsSnapshot.docs.length;
    }

    // 3. Get active chats
    final chatsSnapshot = await _firestore.collection('chats').get();
    final activeChats = chatsSnapshot.docs.length;

    return DashboardStats(
      totalUsers: totalUsers,
      symptomsLoggedToday: symptomsToday,
      activeChats: activeChats,
    );
  }
}
