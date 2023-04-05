import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';

class MoodModel {
  String idFrom;
  String timestamp;
  String content;
  String type;
  List<String> like;
  List<String> loveIt;
  List<String> sad;
  List<String> angry;

  MoodModel({required this.idFrom,
    required this.timestamp,
    required this.content,
    required this.type,
    required this.like,
    required this.angry,
    required this.loveIt,
    required this.sad
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFrom: idFrom,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.content: content,
      FirestoreConstants.type: type,
      FirestoreConstants.like: like,
      FirestoreConstants.angry: angry,
      FirestoreConstants.loveIt: loveIt,
      FirestoreConstants.sad: sad,
    };
  }

  factory MoodModel.fromDocument(DocumentSnapshot documentSnapshot) {
    String idFrom = documentSnapshot.get(FirestoreConstants.idFrom);
    String timestamp = documentSnapshot.get(FirestoreConstants.timestamp);
    String content = documentSnapshot.get(FirestoreConstants.content);
    String type = documentSnapshot.get(FirestoreConstants.type);
    List<String> like = List.from(documentSnapshot.get(FirestoreConstants.like));
    List<String> angry = List.from(documentSnapshot.get(FirestoreConstants.angry));
    List<String> loveIt = List.from(documentSnapshot.get(FirestoreConstants.loveIt));
    List<String> sad = List.from(documentSnapshot.get(FirestoreConstants.sad));

    return MoodModel(idFrom: idFrom, timestamp: timestamp, content: content,
        type: type, like: like, angry: angry, loveIt: loveIt, sad: sad);
  }

  @override
  String toString(){
    return "From:$idFrom Type:$type Content:$content time:$timestamp";
  }
}