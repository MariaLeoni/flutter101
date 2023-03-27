import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../misc/global.dart';
import 'followsModel.dart';

class Follows extends StatefulWidget {

  List<String>? follow;
  String user;
  FFType type;

  Follows({super.key, this.follow, required this.user, required this.type});

  @override
  FollowsState createState() => FollowsState();
}


class FollowsState extends State<Follows> {
  String? userName;
  String? userImage;
  String? userId;
  List<String>? followers = List.empty(growable: true);

  FollowsState({
    this.userName,
    this.userId,
    this.followers,
    this.userImage
  });

  buildView() {
    String noUsers;
    if (widget.type == FFType.following){
      noUsers = "${widget.user} is not following any user";
    }
    else {
      noUsers = "${widget.user} has no followers";
    }
    if (widget.follow == null || widget.follow!.isEmpty){
      return Center(child: Text(noUsers, style: const TextStyle(fontSize: 20),));
    }
    else{
      final firebaseCollection = FirebaseFirestore.instance.collection('users');
      return StreamBuilder(
          stream: firebaseCollection.where(FieldPath.documentId, whereIn: widget.follow).snapshots(),
          builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting ) {
              return const Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.connectionState == ConnectionState.active) {
              if(snapshot.data!.docs.isNotEmpty){{
                  List<FollowerModel> followers = [];
                  for (var doc in snapshot.data!.docs) {

                    followers.add(FollowerModel.fromDocument(doc));
                  }
                  return ListView(
                    children: followers,
                  );
                }
              }
              else if (snapshot.data!.docs.isEmpty) {
                return Center(child: Text(noUsers, style: const TextStyle(fontSize: 20),));
              }
            }
            return const Center(
              child: Text('Something went wrong',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            );
          }
      );
    }
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
          title: Text("${widget.user}'s ${widget.type.name}s"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: buildView()),
            const Divider(),
          ],
        )
    );
  }
}