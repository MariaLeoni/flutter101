import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Comments/CommentItem.dart';
import '../Comments/SubComment.dart';
import '../home_screen/post.dart';
import '../misc/global.dart';
import '../owner_details/owner_details.dart';
import '../ownerdetailsvid/owner_detailsvid.dart';
import '../search_post/users_specifics_page.dart';
import 'feedpost.dart';

class ActivityFeed extends StatefulWidget {

  @override
  State<ActivityFeed> createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Widget? mediaPreview;
  String? activityItemText;

  @override
  void initState() {
    super.initState();
  }

  handNavigation(FeedPost feed, Post post, PostType postType){
    if (feed.type == 'likePost'){
      goToPostDetails(postType, post);
    }
    else{
      loadComment(feed, post, postType);
    }
  }

  void goToPostDetails(PostType postType, Post post) {
    if (postType == PostType.image){
      Navigator.push(context, MaterialPageRoute(builder: (_) =>
          OwnerDetails(img: post.source, userImg: post.userImage, name: post.userName,
            date: post.createdAt, docId: post.id, userId: post.email,
            downloads: post.downloads, viewCount: post.viewCount,
            postId: post.postId, likes: post.likes,
            viewers: post.viewers, description: post.description,
          )));
    }
    else{
      Navigator.push(context, MaterialPageRoute(builder:(_)  => VideoDetailsScreen(
        vid:post.source, userImg: post.userImage, name: post.userName,
        date: post.createdAt, docId: post.id, userId: post.email,
        downloads: post.downloads, description: post.description,
        likes: const [], postId: post.postId,
      )));
    }
  }

  loadComment(FeedPost feed, Post post, PostType postType) async {
    var comment = await firestore.collection('comment')
        .where("comment", isEqualTo: feed.commentData).get();
    navigateToComment(comment, postType, post);
  }

  void navigateToComment(QuerySnapshot<Map<String, dynamic>> comment,
      PostType postType, Post post) {
    CommentItem commentItem = CommentItem.fromDocument(comment.docs.first);

    goToPostDetails(postType, post);

    Navigator.push(context, MaterialPageRoute(
        builder: (_) => SubComment(commentItem: commentItem)));
  }

  prepareNavigation(FeedPost feed) async {
    if (feed.type == 'follow') {
      goToUserProfile(feed);
    }
    else {
      String? postId = feed.postId;
      Map<String, dynamic>? data;
      PostType postType;
      var snapshot = await firestore.collection('wallpaper').doc(postId).get();
      data = snapshot.data();
      if (data == null){
        snapshot = await firestore.collection('wallpaper2').doc(postId).get();
        data = snapshot.data();
        postType = PostType.video;
      }
      postType = PostType.image;
      Post post = Post.getPostSnapshot(data as Map<String, dynamic>, postType);

      handNavigation(feed, post, postType);
    }
  }

  void goToUserProfile(FeedPost feed) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => UsersProfilePage(
      userId: feed.userId,
      userName: feed.name,
      userImage: feed.userProfileImage,
    )));
  }

  Widget listViewWidget (String image, String name, String? postId, DateTime timestamp,
      String type, String userId, String userProfileImage, String commentData,
      String description, String postOwnerId, String postOwnerName, String postOwnerImage,
      List<String>? likes, int downloads, String activityId, bool readStatus ) {

    if (type.contains("like") || type == 'comment'|| type == 'follow'|| type == 'tag' || type =='commentReply') {
      mediaPreview = SizedBox(
              height: 50.0,
              width: 50.0,
              child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(image),
                        )
                    ),
                  )
              )
          );
    } else{
      mediaPreview = Container();
    }
    if (type == 'likePost') {
      activityItemText = "liked your post";
    }
    else if (type == 'likeComment') {
      activityItemText = " liked your comment: $commentData";
    }
    else if (type == 'comment') {
      activityItemText = 'commented: $commentData';
    } else if (type == 'follow') {
      activityItemText = ' started following you';
    } else if (type == 'tag'){
      activityItemText = ' tagged you in a post';
    }else if (type == 'commentReply'){
      activityItemText = 'replied: $commentData';
    }
    else {
      activityItemText = "Update '$type'";
    }

    return Padding(
        padding:const EdgeInsets.only(bottom: 2.0),
        child: Container(
            color: Colors.grey.shade900,
            child: GestureDetector(
                onTap: () {
                  FeedPost feedPost = FeedPost(image: image, name: name, postId: postId,
                    timestamp: timestamp, type: type, userId: userId,
                    userProfileImage: userProfileImage, commentData: commentData,
                    description: description, postOwnerId: postOwnerId,
                    postOwnerName: postOwnerName, postOwnerImage: postOwnerImage,
                    likes: likes, downloads: downloads, activityId: activityId,
                    readStatus: readStatus);

                    prepareNavigation(feedPost);

                  firestore.collection('Activity Feed')
                      .doc(_auth.currentUser!.uid).collection('FeedItems')
                      .doc(activityId).update({'Read Status': true });
                },
                child: ListTile(
                  title: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UsersProfilePage(
                        userId: userId,
                        userName: name,
                        userImage: userProfileImage,
                      ))),
                      child: RichText(
                          overflow: TextOverflow. ellipsis,
                          text: TextSpan(
                              style: const TextStyle(
                                fontSize:14.0,
                                color:Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color:Colors.white),
                                ),
                                TextSpan(
                                  text: ' $activityItemText', style: TextStyle(color:Colors.white)
                                ),
                              ]
                          )
                      )
                  ),
                  leading: readStatus == false ?
                  const Icon(Icons.notifications_active_outlined, color: Colors.red) : const Icon(Icons.notifications_none, color: Colors.green),
                  subtitle: Text(
                    DateFormat("dd MMM, yyyy - hh:mm a").format(timestamp).toString(),
                    overflow: TextOverflow.ellipsis, style:TextStyle(color: Colors.white)
                  ),
                  trailing: SizedBox(width: 50, height: 50,
                    child:mediaPreview,
                ))
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( appBar: AppBar(
      flexibleSpace:Container(
    color: Colors.grey.shade900,
      ),
      title:const Text('Activity Feed',
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
      body: StreamBuilder(
        stream: firestore.collection('Activity Feed')
            .doc(_auth.currentUser!.uid).collection('FeedItems')
            .where("Read Status", isEqualTo: false)
            .orderBy('timestamp', descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting ) {
            return const Center(child: CircularProgressIndicator(),);
          }
          else if (snapshot.connectionState == ConnectionState.active) {
            if(snapshot.data!.docs.isNotEmpty){
              {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    FeedPost feed = FeedPost.getPost(snapshot, index);

                    return listViewWidget(feed.image, feed.name, feed.postId,
                      feed.timestamp,feed.type, feed.userId, feed.userProfileImage,
                      feed.commentData, feed. description, feed.postOwnerId,
                      feed.postOwnerName, feed.postOwnerImage, feed.likes,
                      feed.downloads, feed.activityId,feed.readStatus,
                    );
                  },
                );
              }
            }
            else {
              return const Center(
                  child: Text("There are no Activities",
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
        },
      ),
      backgroundColor: Colors.grey.shade900,
    );
  }
}
