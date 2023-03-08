import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'constants.dart';

class ChatUser extends Equatable {
  final String id;
  final String photoUrl;
  final String displayName;
  final String phoneNumber;
  final String aboutMe;
  List<String>? chatWith = List.empty(growable: true);

  ChatUser({required this.id,
        required this.photoUrl,
        required this.displayName,
        required this.phoneNumber,
        required this.aboutMe,
        required this.chatWith,});

  ChatUser copyWith({
    String? id,
    String? photoUrl,
    String? nickname,
    String? phoneNumber,
    String? email,
    List<String>? chatWith}) => ChatUser(
          id: id ?? this.id,
          photoUrl: photoUrl ?? this.photoUrl,
          displayName: nickname ?? displayName,
          phoneNumber: phoneNumber ?? this.phoneNumber,
          aboutMe: email ?? aboutMe,
          chatWith: chatWith ?? chatWith);

  Map<String, dynamic> toJson() => {
    FirestoreConstants.displayName: displayName,
    FirestoreConstants.photoUrl: photoUrl,
    FirestoreConstants.phoneNumber: phoneNumber,
    FirestoreConstants.aboutMe: aboutMe,
  };

  factory ChatUser.fromDocument(DocumentSnapshot snapshot) {
    String photoUrl = "";
    String nickname = "";
    String phoneNumber = "";
    String aboutMe = "";
    List<String> chatWith = List.empty(growable: true);

    try {
      photoUrl = snapshot.get(FirestoreConstants.photoUrl);
      nickname = snapshot.get(FirestoreConstants.displayName);
      phoneNumber = snapshot.get(FirestoreConstants.phoneNumber);
      aboutMe = snapshot.toString().contains(FirestoreConstants.aboutMe) ? snapshot.get(FirestoreConstants.aboutMe) : "";
      chatWith = snapshot.toString().contains(FirestoreConstants.chatWith) ? snapshot.get(FirestoreConstants.chatWith) : List.empty();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return ChatUser(
        id: snapshot.id,
        photoUrl: photoUrl,
        displayName: nickname,
        phoneNumber: phoneNumber,
        aboutMe: aboutMe,
        chatWith: chatWith);
  }
  // TODO: implement props
  List<Object?> get props => [id, photoUrl, displayName, phoneNumber, aboutMe, chatWith];
}