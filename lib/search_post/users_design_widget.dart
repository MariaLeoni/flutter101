import 'package:flutter/material.dart';
import 'package:sharedstudent1/search_post/user.dart';
import 'package:sharedstudent1/search_post/users_specific_posts.dart';
import 'package:sharedstudent1/search_post/users_specifics_page.dart';

class UsersDesignWidget extends StatefulWidget {

  Users? model;
  BuildContext? context;

  UsersDesignWidget({super.key, this.model, this.context,});

  @override
  State<UsersDesignWidget> createState() => UsersDesignWidgetState();
}

class UsersDesignWidgetState extends State<UsersDesignWidget> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => UsersProfilePage(
          userId:widget.model!.id,
          userName:widget.model!.name,
          userImage: widget.model!.userImage,
        )));
      },
      child: Card(
        color: Colors.grey.shade900,
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:SizedBox(
                  height: 240,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.red.shade600,
                          minRadius: 90.0,
                          child: CircleAvatar(
                              radius:80.0,
                              backgroundImage: NetworkImage(
                                widget.model!.userImage!,
                              )
                          )
                      ),
                      const SizedBox(height: 10.0,),
                      Text(widget.model!.name!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: "Bebas",
                          )
                      ),
                      const SizedBox (height: 5.0,),
                      Text(widget.model!.name!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize:16,
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
