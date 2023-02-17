import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'FollowerModel.dart';

class Followers extends StatefulWidget {

  List<String>? followers;

  Followers({super.key, this.followers});

  @override
  FollowersState createState() => FollowersState();
}


class FollowersState extends State<Followers> {
  String? userName;
  String? userImage;
  String? userId;
  List<String>? followers = List.empty(growable: true);

  FollowersState({
    this.userName,
    this.userId,
    this.followers,
    this.userImage
  });

  buildFollowers() {
    final firebaseCollection = FirebaseFirestore.instance.collection('users');

    return StreamBuilder(
        stream: firebaseCollection.where(
            FieldPath.documentId, whereIn: widget.followers).snapshots(),
        builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting ) {
            return const Center(child: CircularProgressIndicator(),);
          }
          else if (snapshot.connectionState == ConnectionState.active) {
            if(snapshot.data!.docs.isNotEmpty){
              {
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
              return const Center(
                  child: Text("This user has no followers ",
                    style: TextStyle(fontSize: 20),)
              );
            }
          }
          return const Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          );
        }
        // builder: (context, snapshot) {
        //   if (snapshot.hasError) {
        //     return const Text('Something went wrong');
        //   }
        //   if (snapshot.connectionState == ConnectionState.waiting) {
        //     return const Center(child: CircularProgressIndicator(),);
        //   }
        //   List<FollowerModel> followers = [];
        //   for (var doc in snapshot.data!.docs) {
        //     followers.add(FollowerModel.fromDocument(doc));
        //   }
        //   return ListView(
        //     children: followers,
        //   );
        //
        //   }
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
          title: const Text("Followers"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: buildFollowers()),
            const Divider(),
          ],
        )
    );
  }
}