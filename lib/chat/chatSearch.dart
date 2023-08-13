import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../groupInfo.dart';
import '../widgets/widgets.dart';
import 'DatabasService.dart';
import 'groupChatScreen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  String? userImage;
  bool isJoined = false;
  User? user;
  List<QueryDocumentSnapshot>? groupDocumentList = [];
  String userGroupText = '';
  String userId = "";
  String userGroupId = "";

  late DatabaseService databaseService;

  @override
  void initState() {
    super.initState();

    userId = FirebaseAuth.instance.currentUser!.uid;
    user = FirebaseAuth.instance.currentUser;

    databaseService = DatabaseService(uid: userId);
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    await FirebaseFirestore.instance.collection("users").doc(userId).get()
        .then((snapshot) async { if (snapshot.exists) {
      setState(() {
        userName = snapshot.data()!["name"];
        userImage = snapshot.data()!["userImage"];
        userGroupId = "${userId}_$userName";
      });
    }
    });
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black,],
            ),
          ),
        ),
        title: TextField(
          onChanged: (textEntered) {
            setState(() {
              userGroupText = textEntered;
            });
          },
          decoration: InputDecoration(hintText: "Search here...",
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: IconButton(icon: const Icon(Icons.search, color: Colors.white,),
              onPressed: () {},
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: databaseService.getGroups(null).snapshots(),
          builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
            groupDocumentList = snapshot.data?.docs;

            if (userGroupText.isNotEmpty) {
              groupDocumentList = groupDocumentList?.where((group) {
                return group.get("groupName")
                    .toString()
                    .toLowerCase()
                    .contains(userGroupText.toLowerCase());
              }).toList();
            }

            return snapshot.hasData ? Container(color: Colors.black,
                child: ListView.builder(itemCount: groupDocumentList?.length, itemBuilder: (context, index) {
                  Groups model = Groups.fromJson(snapshot.data!.docs[index].data()! as Map<String, dynamic>);
                  return SearchGroupTile(model: model, context: context,);
                })
            ):
            const Center(child: Text("No Record Exists",
              style: TextStyle(fontSize: 20.0, color: Colors.black,
                fontWeight: FontWeight.bold,
              ),),);
          }
      ),
    );
  }

  Widget SearchGroupTile({required Groups model, required BuildContext context}) {
    var groupName = model.groupName!;
    isJoined = model.members.contains(userGroupId);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.red.shade900,
        child: Text(
          model.groupName!.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title:
      Text(model.groupName!, style: const TextStyle(fontWeight: FontWeight.w600, color:Colors.white)),
      subtitle: Text("Admin: ${getName(model.admin!)}", style: TextStyle(color:Colors.white),),
      trailing: InkWell(
        onTap: () async {
          await databaseService.toggleGroupJoin(model.groupId!, userName, model.groupName!);
          isJoined = await databaseService.isUserJoined(groupName, model.groupId!);
          bool localIsJoined = await databaseService.isUserJoined(groupName, model.groupId!);
          setState(() {
            isJoined = localIsJoined;
          });

          if (isJoined) {
            showSnackbar(context, Colors.green, "You have successfully joined the group");

            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(context, ChatPage(groupId: model.groupId!,
                groupName: model.groupName!, userName: userName,
                userImage: userImage!, userId: userId));
            });
          }
          else{
            showSnackbar(context, Colors.red, "You have left the group $groupName");
          }
        },
        child: isJoined ? Container(decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.red.shade900, border: Border.all(color: Colors.white, width: 1),
        ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Text("Joined", style: TextStyle(color: Colors.white),),
        ) : Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
            color: Colors.blue.shade900,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Text("Join Now", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}