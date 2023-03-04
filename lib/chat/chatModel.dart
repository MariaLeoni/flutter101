import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';

class ChatMessages {
  String idFrom;
  String idTo;
  String timestamp;
  String content;
  String type;
  bool mine;
  String? thumbnail;

  ChatMessages({required this.idFrom,
        required this.idTo,
        required this.timestamp,
        required this.content,
        required this.type,
        required this.mine,
        required this.thumbnail,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFrom: idFrom,
      FirestoreConstants.idTo: idTo,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.content: content,
      FirestoreConstants.type: type,
      FirestoreConstants.mine: mine,
      FirestoreConstants.thumbnail: thumbnail
    };
  }

  factory ChatMessages.fromDocument(DocumentSnapshot documentSnapshot) {
    String idFrom = documentSnapshot.get(FirestoreConstants.idFrom);
    String idTo = documentSnapshot.get(FirestoreConstants.idTo);
    String timestamp = documentSnapshot.get(FirestoreConstants.timestamp);
    String content = documentSnapshot.get(FirestoreConstants.content);
    String type = documentSnapshot.get(FirestoreConstants.type);
    bool mine = documentSnapshot.get(FirestoreConstants.mine);
    String thumbnail = documentSnapshot.get(FirestoreConstants.thumbnail);

    return ChatMessages(idFrom: idFrom, idTo: idTo,
        timestamp: timestamp, content: content, type: type,
        mine: mine, thumbnail: thumbnail);
  }

  @override
  String toString(){
    return "From:$idFrom To:$idTo Type:$type Thumbnail:$thumbnail time:$timestamp";
  }
}