import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'package:sharedstudent1/search_userpost/postmodel.dart';
import '../search_post/user.dart';
import '../search_post/users_design_widget.dart';
import '../search_post/users_post_widget.dart';


class SearchScreen extends StatefulWidget {

  SearchType? type;
  SearchScreen({super.key, this.type,});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {

  Future<QuerySnapshot>? postDocumentsList;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String userPostText = '';

  void startSearch(String searchText) {
    if (widget.type == SearchType.post){
      postDocumentsList = firestore.collection("wallpaper")
          .where("description", isGreaterThanOrEqualTo: searchText).
           where("description", isLessThanOrEqualTo: '$searchText\uf8ff').get();
    }
    else{
      postDocumentsList = firestore.collection("users")
          .where("name", isGreaterThanOrEqualTo: searchText)
          .where("name", isLessThanOrEqualTo: '$searchText\uf8ff').get();
    }

    setState(() {
      postDocumentsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade800, Colors.red,],
            ),
          ),
        ),
        title: TextField(
          onChanged: (textEntered) {
            setState(() {
              userPostText = textEntered;
            });
            startSearch(textEntered);
          },
          decoration: InputDecoration(
            hintText: "Search here...",
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.white,),
              onPressed: () {
                startSearch(userPostText);
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
          future: postDocumentsList,
          builder: (context, snapshot) {
            return snapshot.hasData ?
            Container(
                color: Colors.black,
                child: ListView.builder(
                    itemCount: snapshot.data!.docs.length, itemBuilder: (context, index) {
                  if (widget.type == SearchType.post){
                    PostModel model = PostModel.fromJson(snapshot.data!.docs[index].data()! as Map<String, dynamic>);
                    return UsersPostWidget(model: model, context: context);
                  }
                  else{
                    Users model = Users.fromJson(
                        snapshot.data!.docs[index].data()! as Map<String, dynamic>);
                    return UsersDesignWidget(model: model, context: context,);
                  }
                }
                )
            ):
            const Center(child: Text("No Record Exists",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),),);
          }
      ),
      backgroundColor: Colors.black,
    );
  }
}