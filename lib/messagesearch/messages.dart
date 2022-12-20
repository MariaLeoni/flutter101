import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import'package:cached_network_image/cached_network_image.dart';


class message extends StatefulWidget {

  String? userId;
  String?userName;
  String? postId;
  String? docId;


  message({super.key, this.userId, this.postId,
    this.docId,this.userName});

  @override
  State<message> createState() => messageState(
    postId: this.postId,
    userId: this.userId,);
}


class messageState extends State<message> {
  String? postId;
  String? userId;
  String? myImage;
  String? myName;
  String? Id;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? myUserId;

  messageState({
    String? postId,
    String? userId,
  });

  TextEditingController commentController = TextEditingController();


  buildComments(){
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('comment').doc(widget.postId).collection('comments').orderBy("timestamp", descending: false).snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return const Text('Loading');
        }
        List<Comments> message =[];
        snapshot.data!.docs.forEach((doc){
          message.add(Comments.fromDocument(doc));
        });

        return ListView(
          children: message,
        );
      },

    );
  }
  addComment() {
    FirebaseFirestore.instance.collection('comment').doc(widget.postId).collection('comments').add({
      "comment": commentController.text,
      "userImage": myImage,
      "userName" : myName,
      "timestamp": DateTime.now(),
      "userId": Id,
    });

    commentController.clear();
  }

  void read_userInfo()async
  {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot)
    {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
      Id = snapshot.get('id');
    });
  }


  @override
  void initState() {
    super.initState();
    myUserId = _auth.currentUser!.uid;
    read_userInfo();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.2, 0.9],
              ),
            ),
          ),
          title: Text(
            widget.userName!,
        ),
      centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: buildComments()),
            const Divider(),

            //

            ListTile(
                title: TextFormField(
                  controller: commentController,
                  decoration: InputDecoration(labelText: "Write a comment.."),
                ),
                trailing: OutlinedButton(
                  onPressed: addComment,
                  //  borderSide: BorderSide.none,
                  child: Text("Post"),
                )
            ),
          ],
        )
    );
  }

}

class Comments extends StatelessWidget {
  String? userName;
  String? userImage;
  String? userId;
  String? comment;
  Timestamp? timestamp;

  Comments({
    this.userName,
    this.userImage,
    this.userId,
    this.comment,
    this.timestamp,
  });

  factory Comments.fromDocument(DocumentSnapshot doc){
    return Comments(
      userName: doc.data().toString().contains('userName')? doc.get('userName'):'',
      userId: doc.data().toString().contains('userId')?doc.get('userId'):'',
      comment: doc.data().toString().contains('comment')?doc.get('comment'):'',
      timestamp: doc.data().toString().contains('timestamp')?doc.get('timestamp'):'',
      userImage: doc.data().toString().contains('userImage')?doc.get('userImage'):'',
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment!),
          leading: CircleAvatar(
            backgroundImage:
            CachedNetworkImageProvider
              (userImage!),
          ),
          // subtitle: Text(timeago.format(timestamp?.toDate())),
        ),
        Divider(),
      ],
    );
  }
}






