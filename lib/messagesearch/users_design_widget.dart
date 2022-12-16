import 'package:flutter/material.dart';
import 'package:sharedstudent1/search_post/user.dart';
import 'package:sharedstudent1/search_post/users_specific_posts.dart';

import 'messages.dart';

class messageUsersDesignWidget extends StatefulWidget {

  Users? model;
  BuildContext? context;

  messageUsersDesignWidget({
    this.model,
    this.context,
});


  @override
  State<messageUsersDesignWidget> createState() => _messageUsersDesignWidgetState();
}

class _messageUsersDesignWidgetState extends State<messageUsersDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()
        {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => message(
            userId: widget.model!.id,
            userName: widget.model!.name,
          )));
        },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 240,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.amberAccent,
                  minRadius: 90.0,
                  child: CircleAvatar(
                    radius:80.0,
                    backgroundImage: NetworkImage(
                      widget.model!.userImage!,
                    )
                  )
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
