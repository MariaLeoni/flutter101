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

  UploadTask uploadImageFile(File image, String filename, String? dir) {
    Reference reference;
    if (dir == null) {
      reference = firebaseStorage.ref().child(filename);
    } else {
      reference = firebaseStorage.ref().child(dir).child(filename);
    }
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
    List users1 =List.empty(growable:true);
    users1.add(userId);
    FirebaseFirestore.instance.collection("users").doc(peerId).update({FirestoreConstants.chatWith:FieldValue.arrayUnion(users1)});
    saved = true;
  }

  // Stream<QuerySnapshot> getMoods(List<String>? followingList) {
  //   return firebaseFirestore.collection(FirestoreConstants.pathMoodCollection)
  //       .where(FirestoreConstants.idFrom, whereIn: followingList)
  //       .where(FirestoreConstants.timestamp, isGreaterThanOrEqualTo: todayDate.add(const Duration(days: -1)))
  //       .orderBy(FirestoreConstants.timestamp, descending: true)
  //       .snapshots();
  // }
  Stream<QuerySnapshot> getMoods() {
    return firebaseFirestore.collection(FirestoreConstants.pathMoodCollection)
       // .where(FirestoreConstants.idFrom, whereIn: followingList)
        .where(FirestoreConstants.timestamp, isGreaterThanOrEqualTo: todayDate.add(const Duration(days: -1)))
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .snapshots();
  }
  void sendMood(String content, PostType type, String currentUserId,
      String name, String imageURL) {

    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMoodCollection)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    documentReference.set({
      FirestoreConstants.idFrom: currentUserId,
      FirestoreConstants.timestamp: DateTime.now(),
      FirestoreConstants.photoUrl: imageURL,
      FirestoreConstants.displayName: name,
      FirestoreConstants.content: content,
      FirestoreConstants.type: type.name,
      FirestoreConstants.like: List<String>.empty(),
      FirestoreConstants.angry: List<String>.empty(),
      FirestoreConstants.loveIt: List<String>.empty(),
      FirestoreConstants.sad: List<String>.empty(),
    });
  }
}