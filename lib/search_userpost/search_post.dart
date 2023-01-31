import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/search_post/user.dart';
import 'package:sharedstudent1/search_post/users_design_widget.dart';
import 'package:sharedstudent1/search_userpost/userx.dart';
import 'package:sharedstudent1/search_userpost/users_design_widget.dart';

import '../home_screen/homescreen.dart';

class SearchUserPost extends StatefulWidget {

  @override
  State<SearchUserPost> createState() => _SearchUserPostState();
}

class _SearchUserPostState extends State<SearchUserPost> {

  Future<QuerySnapshot>? postDocumentsList;
  String userPostText= '';

  initSearchingPost(String textEntered)
  {
   postDocumentsList= FirebaseFirestore.instance
       .collection("wallpaper")
        .where("description", isGreaterThanOrEqualTo: textEntered)
        .get();

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
          onChanged: (textEntered)
          {
           setState(() {
             userPostText= textEntered;
           });
           initSearchingPost(textEntered);
          },
            decoration: InputDecoration(
              hintText: "Search Post Here...",
                  hintStyle: const TextStyle(color: Colors.white54),
                border: InputBorder.none,
              suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.white,),
          onPressed: ()
            {
              initSearchingPost(userPostText);
            },
            ),
            prefixIcon: IconButton(
          icon: const Padding(
            padding: EdgeInsets.only(right: 12.0, bottom:4.0),
           child: Icon(Icons.arrow_back, color: Colors.white,),
            ),
            onPressed: ()
          {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          },
          ),
            ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: postDocumentsList,
      builder: (context, snapshot)
        {
          return snapshot.hasData
              ?
              ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index)
                  {
                    Posts model = Posts.fromJson(
                        snapshot.data!.docs[index].data()! as Map<String, dynamic>
                    );

                    return UsersDesignWidgetx(
                      model: model,
                      context: context,
                    );

                  }
              )
              :
              const Center(child: Text("No Record Exists "),);
        }
    )
    );
  }
}
