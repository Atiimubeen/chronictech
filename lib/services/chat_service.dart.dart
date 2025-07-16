// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  // --- Send message as the logged-in user ---
  Future<void> sendMessage(String messageText) async {
    if (_user == null || messageText.trim().isEmpty) return;

    final message = {
      'text': messageText.trim(),
      'senderId': _user!.uid,
      'timestamp': Timestamp.now(),
    };

    final chatDocRef = _firestore.collection('chats').doc(_user!.uid);
    await chatDocRef.collection('messages').add(message);

    // Update the main chat document with the last message details
    await chatDocRef.set({
      'lastMessage': messageText.trim(),
      'lastMessageTimestamp': Timestamp.now(),
      'userName': _user!.displayName ?? _user!.email?.split('@')[0],
      'userId': _user!.uid,
    }, SetOptions(merge: true));
  }

  // --- Send message as an admin to a specific user ---
  Future<void> sendMessageByAdmin({
    required String userId,
    required String messageText,
  }) async {
    if (messageText.trim().isEmpty) return;

    final message = {
      'text': messageText.trim(),
      'senderId': 'admin', // Use a special ID for admin messages
      'timestamp': Timestamp.now(),
    };

    final chatDocRef = _firestore.collection('chats').doc(userId);
    await chatDocRef.collection('messages').add(message);

    await chatDocRef.set({
      'lastMessage': messageText.trim(),
      'lastMessageTimestamp': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  // --- Get messages for the current logged-in user's chat ---
  Stream<QuerySnapshot> getChatMessages() {
    if (_user == null) return const Stream.empty();
    return _firestore
        .collection('chats')
        .doc(_user!.uid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- Get messages for a specific user (for the admin) ---
  Stream<QuerySnapshot> getMessagesForUser(String userId) {
    return _firestore
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
