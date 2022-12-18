import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/Comments/Commentx.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

class Comment extends StatefulWidget {

  String? userId;
  String? postId;
  String? docId;

  Comment({super.key, this.userId, this.postId,
    this.docId,});

  @override
  State<Comment> createState() => CommentState(
    postId: this.postId,
    userId: this.userId,);
}


class CommentState extends State<Comment> {
  String? postId;
  String? userId;
  String? myImage;
  String? myName;
  String? Id;
  String commentId = const Uuid().v4();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? myUserId;

  CommentState({
    String? postId,
    String? commentId,
    String? userId,
  });

  TextEditingController commentController = TextEditingController();


  buildComments(){
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('comment').doc(widget.postId).collection('comments').orderBy("timestamp", descending: false).snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        List<Comments> comment =[];
        snapshot.data!.docs.forEach((doc){
          comment.add(Comments.fromDocument(doc));
        });

        return ListView(
          children: comment,
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
      "commentId":commentId,
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
            title: Text("Comments"),
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
   String? commentId;
   Timestamp? timestamp;

  Comments({
    this.userName,
    this.userImage,
     this.userId,
    this.comment,
    this.commentId,
    this.timestamp,
  });
   TextEditingController commentController1 = TextEditingController();
   addComment() {
     FirebaseFirestore.instance.collection('comment').doc(commentId).collection('comments').add({
       "comment": commentController1.text,
       "userImage": userImage,
       "userName" : userName,
       "timestamp": DateTime.now(),
       "userId": userId,
       "commentId":commentId,
     });

     commentController1.clear();
   }
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
          subtitle: Text(userName!),
          trailing: Icon
            (Icons.arrow_drop_down),
    onTap: (){
            addComment;
         //  trailing: OutlinedButton(
            // onPressed: addComment,
             //  borderSide: BorderSide.none,
           //  child: Text("Post"),
           //);

    },
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






