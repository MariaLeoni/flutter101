import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../misc/global.dart';
import 'chatModel.dart';
import 'constants.dart';

class ChatProvider{

  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

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
      String currentUserId, String peerId) {

    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime
        .now()
        .millisecondsSinceEpoch
        .toString());

    ChatMessages chatMessages = ChatMessages(
        idFrom: currentUserId,
        idTo: peerId,
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        type: type.name,
        mine: true);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, chatMessages.toJson());
    });
  }
}