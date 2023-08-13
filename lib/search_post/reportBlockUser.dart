import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/search_post/user.dart';
import '../misc/global.dart';
import '../widgets/input_field.dart';

class BlockOrReportUser extends StatefulWidget {

  Users? user;
  UserIssueType? userIssueType;

  BlockOrReportUser({super.key, required this.user, required this.userIssueType});

  @override
  State<BlockOrReportUser> createState() => BlockOrReportUserState();
}

class BlockOrReportUserState extends State<BlockOrReportUser> {
  TextEditingController commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? myName;
  String? myEmail;
  String? myUserId;
  late String title;
  late String action;

  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid).get().then<dynamic>((DocumentSnapshot snapshot) {
      myEmail = snapshot.get('email');
      myName = snapshot.get('name');
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.userIssueType == UserIssueType.report){
      action = "Report";
    }
    else{
      action = "Block";
    }
    title = "$action ${widget.user?.name}";
    myUserId = _auth.currentUser?.uid;

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
      readUserInfo();
      title;
      action;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[SliverAppBar(
                flexibleSpace:Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.2],
                    ),
                  ),
                ),
                title: Text(title),
                centerTitle: true, pinned: true, floating: true,),
              ];
            },
            body: Container(color: Colors.black,
              child: Column(
              children: <Widget>[
                const SizedBox(height: 30.0,),
                Text("Hello $myName"),
                const SizedBox(height: 10.0,),
                SizedBox.fromSize(size: const Size(350.0,  200),
                    child: InputField(
                      textEditingController: commentController, hintText: "Could you add a bit reason...", icon: Icons.send,
                       obscureText: false,
                    )
                ),
                const SizedBox(height: 10.0,),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade900),
                      minimumSize: MaterialStateProperty.all(const Size(150, 50))
                  ),
                  onPressed: reportPost,
                  child: Text(action),
                ),
                const SizedBox(height: 30.0,),
              ],
            ),)
        )
    );
  }

  void reportPost(){
    FirebaseFirestore.instance.collection('BlockedOrReported').add({
      'reporterId': myUserId,
      'reporterName': myName,
      'reporterEmail': myEmail,
      'reportedOn': DateTime.now(),
      'userId': widget.user?.id,
      'userName': widget.user?.name,
      'userEmail': widget.user?.email,
      'action': action,
      'report': commentController.text,
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Thanks, ${action.toLowerCase()} sent.")));

    if (widget.userIssueType == UserIssueType.block){
      FirebaseFirestore.instance.collection('users').doc(myUserId)
          .update({'blocked': widget.user?.id,});
      FirebaseFirestore.instance.collection('users').doc(widget.user?.id)
          .update({'blockedBy': myUserId,});
    }
    Navigator.pop(context);
  }
}
