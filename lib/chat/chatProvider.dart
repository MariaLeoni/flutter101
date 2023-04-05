import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../misc/global.dart';
import 'chatModel.dart';
import 'constants.dart';

class ChatProvider{

  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  bool saved = false;
  final todayDate = DateTime.now();

  ChatProvider({
        required this.firebaseStorage,
        required this.firebaseFirestore});

  UploadTask uploadImageFile(File image, String filename) {
    Reference reference = firebaseStorage.ref().child(filename);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateFirestoreData(String collectionPath, String docPath,
      Map<String, dynamic> dataUpdate) {

    return firebaseFirestore.collection(collectionPath)
        .doc(docPath).update(dataUpdate);
  }

  Stream<QuerySnapshot> getChatMessage(String groupChatId, int limit) {
    return firebaseFirestore.collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId).collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  void sendChatMessage(String content, PostType type, String groupChatId,
      String currentUserId, String peerId, String? thumbnail) {

    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    ChatMessages chatMessages = ChatMessages(
        idFrom: currentUserId,
        idTo: peerId,
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        type: type.name,
        mine: true,
        thumbnail: thumbnail);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, chatMessages.toJson());
    });

    if (saved == false) {
      updateDMers(currentUserId, peerId);
    }
  }

  void updateDMers(String userId, String peerId) {
    List users = List.empty(growable: true);
    users.add(peerId);
    FirebaseFirestore.instance.collection("users")
        .doc(userId).update({FirestoreConstants.chatWith: FieldValue.arrayUnion(users)
    });
    saved = true;
  }

  Stream<QuerySnapshot> getMoods(List<String>? followingList) {
    print("followingList $followingList");
    return firebaseFirestore.collection(FirestoreConstants.pathMoodCollection)
        .where(FieldPath.documentId, whereIn: followingList)
        .where(FirestoreConstants.timestamp, isGreaterThanOrEqualTo: todayDate)
        //.orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(2000).snapshots();
  }
}