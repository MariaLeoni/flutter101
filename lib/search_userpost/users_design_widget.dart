import 'package:flutter/material.dart';
import 'package:sharedstudent1/search_post/user.dart';
import 'package:sharedstudent1/search_post/users_specific_posts.dart';
import 'package:sharedstudent1/search_userpost/userx.dart';

class UsersDesignWidgetx extends StatefulWidget {

  Posts? model;
  BuildContext? context;

  UsersDesignWidgetx({
    this.model,
    this.context,
});


  @override
  State<UsersDesignWidgetx> createState() => _UsersDesignWidgetxState();
}

class _UsersDesignWidgetxState extends State<UsersDesignWidgetx> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()
        {
          print("postId ${widget.model!.postId} description${widget.model!.description}");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UsersSpecificPostsScreen(
            userId: widget.model!.postId,
            userName: widget.model!.name,

          )));
        },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
            height: 600,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Image.network(
                      widget.model!.Image!,
                    ),

                SizedBox(height: 10.0,),
                Text(
                  widget.model!.name!,
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize: 20,
                    fontFamily: "Bebas",
                  )
                ),
                SizedBox (height: 10.0,),
                Text(
                  widget.model!.email!,
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize:12,
                  ),
                )
              ],
            )
          )
        )
      ),
    );
  }
}
