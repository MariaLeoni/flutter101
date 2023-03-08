import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharedstudent1/chat/userModel.dart';
import 'constants.dart';

class ChatUsersProvider {
  final FirebaseFirestore firebaseFirestore;
  final List<String> chatees;

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  ChatUsersProvider({required this.firebaseFirestore, required this.chatees});

  Future<void> updateFirestoreData(
      String collectionPath, String path, Map<String, dynamic> updateData) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(updateData);
  }

  Stream<QuerySnapshot> getFirestoreData(String collectionPath, int limit,
      String? textSearch, List<String>? userList) {
    if (textSearch?.isNotEmpty == true) {
      return firebaseFirestore
          .collection(collectionPath)
          .limit(limit)
          .where(FirestoreConstants.displayName, isEqualTo: textSearch)
          .where(FirestoreConstants.id, isNotEqualTo: currentUserId)
          .snapshots();
    } else {
      return firebaseFirestore
          .collection(collectionPath)
          .limit(limit)
          .where(FieldPath.documentId, whereIn: userList)
          .snapshots();
    }
  }

  Stream<QuerySnapshot> getChatUsers(String userId, int limit) {
    return getFirestoreData(FirestoreConstants.pathUserCollection,
        chatees.length, null, chatees);
  }

  Future<ChatUser> getUser(userId) async {
    final userCollection = firebaseFirestore.collection(FirestoreConstants.pathUserCollection);
    var chatWith = await userCollection.doc(userId).snapshots().first;
    return ChatUser.fromDocument(chatWith);
  }
}