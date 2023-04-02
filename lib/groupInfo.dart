import'package:cloud_firestore/cloud_firestore.dart';

class Groups {
  String? admin;
  String? groupId;
  String? groupName;
  String? groupIcon;

  Groups({
    this.admin,
    this.groupId,
    this.groupName,
    this.groupIcon,
  });

  Groups.fromJson(Map<String, dynamic> json){
    admin = json['admin'];
    groupId = json['groupId'];
    groupName = json ['groupName'];
    groupIcon = json ['groupIcon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['admin'] = admin;
    data['groupId'] = groupId;
    data['groupName'] = groupName;
    data['groupIcon'] = groupIcon;


    return data;
  }
}
