import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';

class MoodModel {
  String moodId;
  String idFrom;
  String? photoUrl;
  String displayName;
  Timestamp timestamp;
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
    required this.sad,
    required this.photoUrl,
    required this.displayName,
    required this.moodId,
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
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.displayName: displayName,
    };
  }

  factory MoodModel.fromDocument(DocumentSnapshot documentSnapshot) {
    String moodId = documentSnapshot.id;
    String idFrom = documentSnapshot.get(FirestoreConstants.idFrom);
    Timestamp timestamp = documentSnapshot.get(FirestoreConstants.timestamp);
    String content = documentSnapshot.get(FirestoreConstants.content);
    String type = documentSnapshot.get(FirestoreConstants.type);
    List<String> like = List.from(documentSnapshot.get(FirestoreConstants.like));
    List<String> angry = List.from(documentSnapshot.get(FirestoreConstants.angry));
    List<String> loveIt = List.from(documentSnapshot.get(FirestoreConstants.loveIt));
    List<String> sad = List.from(documentSnapshot.get(FirestoreConstants.sad));
    String? photoUrl = documentSnapshot.toString().contains(FirestoreConstants.photoUrl) ?
    documentSnapshot.get(FirestoreConstants.photoUrl) : null;
    String displayName = documentSnapshot.toString().contains(FirestoreConstants.displayName) ?
    documentSnapshot.get(FirestoreConstants.displayName) : "user";

    return MoodModel(idFrom: idFrom, timestamp: timestamp, content: content,
        type: type, like: like, angry: angry, loveIt: loveIt, sad: sad,
        photoUrl: photoUrl, displayName: displayName, moodId: moodId);
  }

  @override
  String toString(){
    return "From:$idFrom Type:$type Content:$content time:$timestamp";
  }
}