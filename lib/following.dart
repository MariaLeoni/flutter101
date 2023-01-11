import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Comments/CommentItem.dart';
class Followers extends StatelessWidget {

  buildComments(){
    final firebaseCollection = FirebaseFirestore.instance.collection('users');

     return StreamBuilder(
       stream: firebaseCollection.where(FieldPath.documentId, whereIn: widget.commentItem!.subCommentsIds!).snapshots(),
       builder: (context, snapshot){
         if (snapshot.hasError) {
           return const Text('Something went wrong');
         }
         if (snapshot.connectionState == ConnectionState.waiting) {
           return const Text('Loading');
         }
         List<Followers> followers = [];
         for (var doc in snapshot.data!.docs) {
           followers.add(CommentItem.fromDocument(doc));
         }
         return ListView(
           children: followers,
         );
       },
     );
  }
  factory Followers.fromDocument(DocumentSnapshot doc){
    return Followers(
      userName: doc.data().toString().contains('commenterName') ? doc.get('commenterName') : '',
      userId: doc.data().toString().contains('commenterId') ? doc.get('commenterId') : '',
      comment: doc.data().toString().contains('comment') ? doc.get('comment') : '',
      timestamp: doc.data().toString().contains('timestamp') ? doc.get('timestamp') : '',
      userImage: doc.data().toString().contains('commenterImage') ? doc.get('commenterImage') : '',
      commentId: doc.data().toString().contains('commentId') ? doc.get('commentId') : '',
      subCommentsIds: doc.data().toString().contains('subCommentIds') ? List.from(doc.get('subCommentIds')) : List.empty(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2],
              ),
            ),
          ),
          title: const Text("Comments"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: buildComments()),
            const Divider(),
            ListTile(
                title: TextFormField(
               //   controller: commentController,
                  decoration: const InputDecoration(labelText: "Write a comment.."),
                ),
                //trailing: OutlinedButton(
                  //onPressed: addComment,
                  //  borderSide: BorderSide.none,
                  //child: const Text("Post"),
                )
            //),
          ],
        )
    );
  }
}
