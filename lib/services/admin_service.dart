// lib/services/admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// A data model to hold the statistics
class AdminDashboardStats {
  final int totalUsers;
  final int newUsersToday;
  final int activeChats;

  AdminDashboardStats({
    required this.totalUsers,
    required this.newUsersToday,
    required this.activeChats,
  });
}

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AdminDashboardStats> getDashboardStats() async {
    // --- Get Total Users ---
    final usersSnapshot = await _firestore.collection('users').get();
    final totalUsers = usersSnapshot.docs.length;

    // --- Get New Users Today ---
    final now = DateTime.now();
    final startOfToday = Timestamp.fromDate(
      DateTime(now.year, now.month, now.day),
    );
    final newUsersSnapshot = await _firestore
        .collection('users')
        .where('createdAt', isGreaterThanOrEqualTo: startOfToday)
        .get();
    final newUsersToday = newUsersSnapshot.docs.length;

    // --- Get Active Chats ---
    final chatsSnapshot = await _firestore.collection('chats').get();
    final activeChats = chatsSnapshot.docs.length;

    return AdminDashboardStats(
      totalUsers: totalUsers,
      newUsersToday: newUsersToday,
      activeChats: activeChats,
    );
  }
}
