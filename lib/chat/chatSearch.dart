import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/widgets/widgets.dart';
import '../groupInfo.dart';
import 'DatabasService.dart';
import 'chatHelper.dart';
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
Future <QuerySnapshot>? GroupDocumentslist;
String UserGroupText = '';
  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async { if (snapshot.exists) {
      setState(() {
        userName = snapshot.data()!["name"];
        userImage = snapshot.data()!["userImage"];
       // image = snapshot.data()!["userImage"];

      });
    }
    });
    // await HelperFunctions.getUserNameFromSF().then((value) {
    //   setState(() {
    //     userName = value!;
    //   });
    // });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }
  void startSearch(String searchText) {


      GroupDocumentslist = FirebaseFirestore.instance.collection("groups")
          .where("groupName", isGreaterThanOrEqualTo: searchText)
          .where("groupName", isLessThanOrEqualTo: '$searchText\uf8ff').get();


    setState(() {
      GroupDocumentslist;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: TextField(
          onChanged: (textEntered) {
            setState(() {
              UserGroupText = textEntered;
            });
            startSearch(textEntered);
          },
          decoration: InputDecoration(hintText: "Search here...",
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.white,),
              onPressed: () {
                startSearch(UserGroupText);
              },
            ),
          ), style: TextStyle(color:Colors.white)
        ),

      //   title: const Text(
      //     "Search",
      //     style: TextStyle(
      //         fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
      //   ),
      // ),
      // body: Column(
      //   children: [
      //     Container(
      //       color: Theme.of(context).primaryColor,
      //       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      //       child: Row(
      //         children: [
      //           Expanded(
      //             child: TextField(
      //               controller: searchController,
      //               onChanged: (textEntered) {
      //                 setState(() {
      //                   searchController.text = textEntered;
      //                 });
      //                 initiateSearchMethod(textEntered);
      //               },
      //               style: const TextStyle(color: Colors.white),
      //               decoration: const InputDecoration(
      //                   border: InputBorder.none,
      //                   hintText: "Search groups....",
      //                   hintStyle:
      //                   TextStyle(color: Colors.white, fontSize: 16),
      //       //           suffixIcon: IconButton(
      //       //         icon: const Icon(Icons.search, color: Colors.white,),
      //       //   onPressed: () {
      //       //     initiateSearchMethod(searchController.text);
      //       //   },
      //       // ),
      //               ),
      //             ),
      //           ),
      //           GestureDetector(
      //             onTap: () {
      //               initiateSearchMethod(searchController.text);
      //             },
      //             child: Container(
      //               width: 40,
      //               height: 40,
      //               decoration: BoxDecoration(
      //                   color: Colors.white.withOpacity(0.1),
      //                   borderRadius: BorderRadius.circular(40)),
      //               child: const Icon(
      //                 Icons.search,
      //                 color: Colors.white,
      //               ),
      //             ),
      //           )
      //         ],
      //       ),
      //     ),
      //     // isLoading
      //     //     ? Center(
      //     //   child: CircularProgressIndicator(
      //     //       color: Theme.of(context).primaryColor),
      //     // )
      //     //     : groupList(),
      //   ],
      // ),
    ),
        body: FutureBuilder<QuerySnapshot>(
        future: GroupDocumentslist,
        builder: (context, snapshot) {
          return snapshot.hasData ?
          Container(
              color: Colors.black,
              child: ListView.builder(itemCount: snapshot.data!.docs.length, itemBuilder: (context, index) {
                Groups model = Groups.fromJson(snapshot.data!.docs[index].data()! as Map<String, dynamic>);
                  return SearchGroupTile(model: model, context: context,);

              })
          ):
          const Center(child: Text("No Record Exists",
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),),);
        }
    ),
    );
  }

  // initiateSearchMethod( String searchText) async {
  //
  //   // if (searchController.text.isNotEmpty) {
  //   //   setState(() {
  //   //     isLoading = true;
  //   //   });
  //     await DatabaseService()
  //         .searchByName(searchText)
  //         .then((snapshot) {
  //       setState(() {
  //         searchSnapshot = snapshot;
  //         isLoading = false;
  //        hasUserSearched = true;
  //       });
  //     });
  //     ListView.builder(
  //       shrinkWrap: true,
  //       itemCount: searchSnapshot!.docs.length,
  //       itemBuilder: (context, index) {
  //         return groupTile(
  //           userName,
  //           searchSnapshot!.docs[index]['groupId'],
  //           searchSnapshot!.docs[index]['groupName'],
  //           searchSnapshot!.docs[index]['admin'],
  //         );
  //       },
  //     );
  //   // }
  // }
  //


  // groupList() {
  //    return hasUserSearched
  //     ?
  //   ListView.builder(
  //     shrinkWrap: true,
  //     itemCount: searchSnapshot!.docs.length,
  //     itemBuilder: (context, index) {
  //       return groupTile(
  //         userName,
  //         searchSnapshot!.docs[index]['groupId'],
  //         searchSnapshot!.docs[index]['groupName'],
  //         searchSnapshot!.docs[index]['admin'],
  //       );
  //     },
  //   )
  //       : Container();
  // }

  joinedOrNot(
      String userName, String groupId, String groupname, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupname, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget SearchGroupTile( {required Groups model, required BuildContext context}
      // String userName, String groupId, String groupName, String admin
  ) {
    // function to check whether user already exists in group
    var groupName = model!.groupName!;
    joinedOrNot(userName, model!.groupId!, model!.groupName!, model!.admin!);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.red.shade900,
        child: Text(
          model!.groupName!.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title:
      Text(model!.groupName!, style: const TextStyle(fontWeight: FontWeight.w600, color:Colors.white)),
      subtitle: Text("Admin: ${getName(model!.admin!)}", style: TextStyle(color:Colors.white)),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid)
              .toggleGroupJoin(model!.groupId!, userName, model!.groupName!, userImage!);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(context, Colors.green, "Successfully joined he group");
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: model!.groupId!,
                      groupName: model!.groupName!,
                      userName: userName,
                  userImage: userImage!,));
            });
          } else {
            setState(() {
              isJoined = !isJoined;
              showSnackbar(context, Colors.red, "Left the group $groupName");
            });
          }
        },
        child: isJoined
            ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 1),
          ),
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Text(
            "Joined",
            style: TextStyle(color: Colors.white),
          ),
        )
            : Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Text("Join Now",
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}