import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/chat/socialHomeScreen.dart';
import 'package:sharedstudent1/widgets/widgets.dart';
import '../search_post/users_specifics_page.dart';
import 'DatabasService.dart';
import '../chat/groupChatHome.dart';

class GroupInfo extends StatefulWidget {
   String? groupId;
  String? groupName;
   String? adminName;
   GroupInfo(
      {Key? key,
         this.adminName,
         this.groupName,
         this.groupId})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  String? image;
  @override
  void initState() {
    getMembers();
    super.initState();
  }

  getMembers() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((val) {
      setState(() {
        members = val;
      });
    });
  }

  String getName(String r) {
    String fullStringWithoutId = r.substring(r.indexOf("_")+1,);
    List<String> name = fullStringWithoutId.split(",");
    if (name.isEmpty) {
      return "";
    } else {
      return name[0];
    }
  }
  String getImage(String r){
    return r.substring(r.indexOf(",")+1);
  }
   String? getImagex(String res) {
     FirebaseFirestore.instance.collection("users")
        .doc(res.substring(0, res.indexOf("_")))
        .get()
        .then((snapshot) async { if (snapshot.exists) {
      setState(() {
        image = snapshot.data()!["userImage"];
      });
    }
    });
    return image;
  }
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
        title: const Text("Group Info"),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Exit"),
                        content:
                        const Text("Are you sure you exit the group? "),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              DatabaseService(
                                  uid: FirebaseAuth
                                      .instance.currentUser!.uid)
                                  .toggleGroupJoin(
                                  widget.groupId!,
                                  getName(widget.adminName!),
                                  widget.groupName!,
                              getImage(FirebaseAuth.instance.currentUser!.uid))
                                  .whenComplete(() {
                                nextScreenReplace(context,  SocialHomeScreen());
                              });
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: Container( color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.grey.shade900),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red.shade900,
                    child: Text(
                      widget.groupName!.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Group: ${widget.groupName}",
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text("Admin: ${getName(widget.adminName!)}", style: TextStyle(color:Colors.white))
                    ],
                  )
                ],
              ),
            ),
            memberList(),
          ],
        ),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(),);
        }
        else if (snapshot.connectionState == ConnectionState.active) {
             if (snapshot.hasData) {
               if (snapshot.data['members'] != null) {
                 if (snapshot.data['members'].length != 0) {
                  return ListView.builder(
                    itemCount: snapshot.data['members'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        child: ListTile(
          leading: GestureDetector(onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (_) =>
                                UsersProfilePage(
                                  userId: getId(
                                      snapshot.data['members'][index]),
                                  userName: getName(
                                      snapshot.data['members'][index]),
                                  userImage: getImage(
                                      snapshot.data['members'][index]),
                                )));
                          },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                getImage(snapshot.data['members'][index]),),
                             // child: Text(
                             //    getName(snapshot.data['members'][index])
                             //        .substring(0, 1)
                             //        .toUpperCase(),
                             //    style: const TextStyle(
                             //        color: Colors.white,
                             //        fontSize: 15,
                             //        fontWeight: FontWeight.bold),
                             //  ),
                            ),),
                          title: Text(getName(snapshot.data['members'][index]),
                              style: TextStyle(color: Colors.white)),
                          //   subtitle: Text(getId(snapshot.data['members'][index])),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text("NO MEMBERS"),
                  );
                }
            //   } else {
            //     return const Center(
            //       child: Text("NO MEMBERS"),
            //     );
            //   }
            } else {
              return Center(
                  child: CircularProgressIndicator(
                    color: Theme
                        .of(context)
                        .primaryColor,
                  ));
            }
          }
          else {
            return const Center(
                child: Text("Sorry, there are no Posts for selection",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),)
            );
          }
        }
        return const Center(
          child: Text('Something went wrong', style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),
          ),
        );
      }
    );
  }
}