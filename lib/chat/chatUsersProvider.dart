import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Stream<QuerySnapshot> getFirestoreData(String collectionPath, int limit,
      String? textSearch) {
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
          .where(FirestoreConstants.id, isNotEqualTo: currentUserId)
          .snapshots();
    }
  }
}