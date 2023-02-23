import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/messagesearch/users_design_widget.dart';
import 'package:sharedstudent1/search_post/user.dart';

import '../home_screen/home.dart';

class messageSearchPost extends StatefulWidget {

  @override
  State<messageSearchPost> createState() => _messageSearchPostState();
}

class _messageSearchPostState extends State<messageSearchPost> {

  Future<QuerySnapshot>? postDocumentsList;
  String userNameText= '';

  initSearchingPost(String textEntered)
  {
   postDocumentsList= FirebaseFirestore.instance
       .collection("users")
        .where("name", isGreaterThanOrEqualTo: textEntered)
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
            colors: [Colors.deepPurple.shade300, Colors.purple,],
          ),
        ),
        ),
        title: TextField(
          onChanged: (textEntered)
          {
           setState(() {
             userNameText= textEntered;
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
              initSearchingPost(userNameText);
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
                    Users model = Users.fromJson(
                        snapshot.data!.docs[index].data()! as Map<String, dynamic>
                    );

                    return messageUsersDesignWidget(
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
