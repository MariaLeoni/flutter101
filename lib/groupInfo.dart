
class Groups {
  String? admin;
  String? groupId;
  String? groupName;
  String? groupIcon;
  List<String> members = List.empty(growable: true);

  Groups({this.admin, this.groupId,
    this.groupName, this.groupIcon, required this.members
  });

  Groups.fromJson(Map<String, dynamic> json){
    admin = json['admin'];
    groupId = json['groupId'];
    groupName = json['groupName'];
    groupIcon = json['groupIcon'];
    members = json.toString().contains("members") ? List.from(json['members']) : List.empty();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['admin'] = admin;
    data['groupId'] = groupId;
    data['groupName'] = groupName;
    data['groupIcon'] = groupIcon;
    data['members'] = members;
    return data;
  }
}
