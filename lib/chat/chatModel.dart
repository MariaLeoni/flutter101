import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';

class ChatMessages {
  String idFrom;
  String idTo;
  String timestamp;
  String content;
  String type;
  bool mine;

  ChatMessages(
      {required this.idFrom,
        required this.idTo,
        required this.timestamp,
        required this.content,
        required this.type,
        required this.mine
      });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFrom: idFrom,
      FirestoreConstants.idTo: idTo,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.content: content,
      FirestoreConstants.type: type,
      FirestoreConstants.mine: mine,
    };
  }

  factory ChatMessages.fromDocument(DocumentSnapshot documentSnapshot) {
    String idFrom = documentSnapshot.get(FirestoreConstants.idFrom);
    String idTo = documentSnapshot.get(FirestoreConstants.idTo);
    String timestamp = documentSnapshot.get(FirestoreConstants.timestamp);
    String content = documentSnapshot.get(FirestoreConstants.content);
    String type = documentSnapshot.get(FirestoreConstants.type);
    bool mine = documentSnapshot.get(FirestoreConstants.mine);

    return ChatMessages(
        idFrom: idFrom,
        idTo: idTo,
        timestamp: timestamp,
        content: content,
        type: type,
        mine: mine);
  }
}