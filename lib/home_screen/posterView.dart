import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/home_screen/flagPost.dart';
import 'package:sharedstudent1/home_screen/post.dart';
import 'package:sharedstudent1/misc/global.dart';
import '../owner_details/owner_detailsvid.dart';
import '../search_post/users_specifics_page.dart';

class PosterView{

  PosterView(this.context, this.post);

  BuildContext context;
  Post post;
  final firebase = FirebaseFirestore.instance;

  final TextEditingController textEditingController = TextEditingController();

  Widget buildPosterView(){
    return ListTile(
        selectedColor: Colors.grey,
        hoverColor: Colors.black,
        leading: FittedBox(child: Column(
          children: [
            Row(children: [
              GestureDetector(
                  onTap: () {
                    if (post.postType == PostType.image){
                      Navigator.push(context, MaterialPageRoute(builder: (_) =>
                          UsersProfilePage(userId: post.id, userName: post.userName, userImage: post.userImage,)));
                    }
                    else{
                      Navigator.push(context, MaterialPageRoute(builder:(_)  => VideoDetailsScreen(
                        vid: post.source, userImg: post.userImage, name: post.userName, date: post.createdAt,
                        docId: post.id, userId: post.postId, downloads: post.downloads, postId: post.postId,
                        likes: post.likes, description: post.description,
                      )));
                    }
                  },
                  child: CircleAvatar(radius: 35,
                      backgroundImage: CachedNetworkImageProvider(post.userImage)
                  )
              ),
              Padding(padding: const EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (post.postType == PostType.image){
                            Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                UsersProfilePage(userId: post.id, userName: post.userName, userImage: post.userImage,)));
                          }
                          else{
                            Navigator.push(context, MaterialPageRoute(builder:(_)  => VideoDetailsScreen(
                              vid: post.source, userImg: post.userImage, name: post.userName, date: post.createdAt,
                              docId: post.id, userId: post.postId, downloads: post.downloads, postId: post.postId,
                              likes: post.likes, description: post.description,
                            )));
                          }
                        },
                        child: Text(post.userName, style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold)
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        DateFormat("dd MMM, yyyy - hh:mm a").format(post.createdAt).toString(),
                        style: const TextStyle(color: Colors.white54,
                            fontWeight: FontWeight.bold),
                      )
                    ]
                ),
              ),
            ]
            ),
          ],)),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.white,),
          color: Colors.white,
          itemBuilder: (context) {
            return[
              const PopupMenuItem<int>( value: 0, child: Text("Flag Post"),),
            ];
          },
          onSelected: (value){
            if(value == 0){
              Navigator.push(context, MaterialPageRoute(builder: (_) =>
                  FlagAPost(post: post,)));
            }
          },)
    );
  }
}