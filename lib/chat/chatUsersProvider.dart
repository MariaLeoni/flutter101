import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharedstudent1/chat/userModel.dart';
import 'constants.dart';

class ChatUsersProvider {
  final FirebaseFirestore firebaseFirestore;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  ChatUsersProvider({required this.firebaseFirestore});

  Future<void> updateFirestoreData(
      String collectionPath, String path, Map<String, dynamic> updateData) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(updateData);
  }

  Stream<QuerySnapshot> getFirestoreData(String collectionPath, int limit, String? textSearch) {
    if (textSearch?.isNotEmpty == true) {
      return firebaseFirestore.collection(collectionPath)
          .limit(limit)
          .where(FirestoreConstants.displayName, isGreaterThanOrEqualTo: textSearch).
          where(FirestoreConstants.displayName, isLessThanOrEqualTo: '$textSearch\uf8ff')
          .snapshots();
    } else {
      return firebaseFirestore.collection(collectionPath)
          .limit(limit)
          .snapshots();
    }
  }

  Future<ChatUser> getUser(userId) async {
    final userCollection = firebaseFirestore.collection(FirestoreConstants.pathUserCollection);
    var chatWith = await userCollection.doc(userId).snapshots().first;
    return ChatUser.fromDocument(chatWith);
  }

  Query<Map<String, dynamic>> getUsersIChatWith(String collectionPath, List<String>? userList) {
      return firebaseFirestore.collection(collectionPath).where(FieldPath.documentId, whereIn: userList);
  }
}