import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../home_screen/post.dart';
import '../owner_details/owner_details.dart';

class UsersPostWidget extends StatefulWidget {

  Post? model;
  BuildContext? context;

  UsersPostWidget({super.key, this.model, this.context,});

  @override
  State<UsersPostWidget> createState() => UsersPostWidgetState();
}

class UsersPostWidgetState extends State<UsersPostWidget> {

  @override
  Widget build(BuildContext context) {
    Post? post = widget.model;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder:(_)  => PictureDetailsScreen(
              img: post.source, userImg: post.userImage, name: post.userName,
              date: post.createdAt, docId: post.id, userId: post.email,
              downloads: post.downloads, postId: post.postId, likes: post.likes,
              description: post.description,
            )));
      },
      child: Padding(
      padding: const EdgeInsets.all (8.0),
      child: Card(
        elevation: 16.0,
        shadowColor: Colors.white10,
        child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.black],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2, 0.9],
              ),
            ),
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), // Image border
                  child: SizedBox.fromSize(
                      size: const Size(500.0, 400.0), // Image radius
                      child: Image.network(post!.source, fit: BoxFit.cover)
                  ),
                ),
                const SizedBox(height: 15.0,),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: Row(
                      children:[
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(
                            post.userImage!,
                          ),
                        ),
                        const SizedBox(width: 10.0,),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Text(
                                post.userName!,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                DateFormat("dd MMM, yyyy - hh:mn a").format(post.createdAt).toString(),
                                style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                              )
                            ]
                        )
                      ]
                  ),
                )
              ],
            )
        ),
      )
    ));
  }
}
