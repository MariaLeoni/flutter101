import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sharedstudent1/home_screen/posterView.dart';
import 'package:sharedstudent1/home_screen/videosHomescreen.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'package:sharedstudent1/uploader/postUploader.dart';
import 'package:sharedstudent1/home_screen/post.dart';
import 'package:uuid/uuid.dart';
import '../Activity Feed/activityFeedScreen.dart';
import '../chat/socialHomeScreen.dart';
import '../misc/userModel.dart';
import '../search.dart';
import '../owner_details/owner_details.dart';
import '../search_post/users_specifics_page.dart';
import '../widgets/lazy_load_scrollview.dart';
import '../widgets/ssbadge.dart';

final themeMode = ValueNotifier(2);

class PictureHomeScreen extends StatefulWidget {
  String category = "";
  UserWithNameAndId? user;

  PictureHomeScreen.forCategory({super.key, required this.category});
  PictureHomeScreen.forUser({super.key, required this.user, });

  @override
  State<PictureHomeScreen> createState() => PictureHomeScreenState();
}

class PictureHomeScreenState extends State<PictureHomeScreen> {
  String changeTitle = "Grid View";
  int activityCount = 0;
  int? total;
  String? name;
  String? image;
  String postId = const Uuid().v4();
  Map<String, List<String>?> interests = {};
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String currentToken;
  String userIdx = FirebaseAuth.instance.currentUser!.uid;
  Size? size;
  Post? classPost;

  bool isLoadingList = false;
  QuerySnapshot? collectionState;
  bool firstLoad = true;
  List<Post> postList = [];
  int initialLoads = 10;
  int nextLoads = 20;

  @override
  void initState() {
    super.initState();
    getPicturePosts();
    getAllProducts();
    getDataFromDatabase();
  }

  void goToDetails(String img, String userImg, String name, DateTime date,
      String docId, String userId, int downloads, int viewCount, String postId,
      List<String>? likes, List<String>? viewers, String description,
      List<String>? downloaders) {

    Navigator.push(context, MaterialPageRoute(builder: (_) =>
        OwnerDetails(
          img: img,
          userImg: userImg,
          name: name,
          date: date,
          docId: docId,
          userId: userId,
          downloads: downloads,
          viewCount: viewCount,
          postId: postId,
          likes: likes,
          viewers: viewers,
          description: description,
          downloaders: downloaders,
        )));
  }

  getAllProducts() async {
    final collection = firestore.collection("Activity Feed")
        .doc(userIdx).collection('FeedItems');
    final query = collection.where("Read Status", isEqualTo: false);
    final countQuery = query.count();
    final AggregateQuerySnapshot snapshot = await countQuery.get();
    activityCount = snapshot.count;
  }

  getDataFromDatabase() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        setState(() {
          name = snapshot.data()!["name"];
          image = snapshot.data()!["userImage"];
        });
      }
    });
  }

  Widget pageViewWidget(String docId, String img, String userImg, String name,
      DateTime date, String userId, int downloads, int viewCount, String postId,
      List<String>? likes, List<String>? viewers, String description,
      List<String>? downloaders) {
    Image image = Image(
        image: CachedNetworkImageProvider(img), fit: BoxFit.cover);
    precacheImage(image.image, context);

    return Padding(
      padding: const EdgeInsets.all (8.0),
      child: Card(
          color: Colors.black,
          elevation: 16.0,
          child: Column(
            children: [
              GestureDetector(
                  onTap: () {
                    debugPrint("Picture tapped");
                    updateViewAndNavigate(
                        viewCount,
                        postId,
                        viewers,
                        img,
                        userImg,
                        name,
                        date,
                        docId,
                        userId,
                        downloads,
                        likes,
                        description,
                        downloaders);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Image border
                    child: SizedBox.fromSize(
                        size: Size(
                            500.0, size == null ? 400 : size!.height * 0.65),
                        // Image radius
                        child: image
                    ),
                  )
              ),
              const SizedBox(height: 12.0,),
              PosterView(context, classPost!).buildPosterView(),
            ],
          )
      ),
    );
  }

  void updateViewAndNavigate(int viewCount, String postId,
      List<String>? viewers, String img,
      String userImg, String name, DateTime date, String docId, String userId,
      int downloads, List<String>? likes, String description,
      List<String>? downloaders) {

    debugPrint("Show picture details");

    total = viewCount + 1;

    if (viewers != null && !viewers.contains(userIdx)) {
      viewers.add(userIdx);
    }

    firestore.collection('wallpaper').doc(postId)
        .update({'viewers': viewers, 'viewcount': total,
    });

    goToDetails(
        img,
        userImg,
        name,
        date,
        docId,
        userId,
        downloads,
        viewCount,
        postId,
        likes,
        viewers,
        description,
        downloaders);
  }

  void updateInterests(Map<String, List<String>?> interests) {
    setState(() {
      this.interests = interests;
    });
  }

  @override
  Widget build(BuildContext context) {
    var activityBadgeView = SSBadge(top: 0, right: 2,
        value: activityCount.toString(),
        child: IconButton(
            icon: const Icon(Icons.doorbell_outlined, color:Colors.white), onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => ActivityFeed()));
        }));
    size = MediaQuery.of(context).size;
    return Scaffold(
        floatingActionButton: Wrap(
          direction: Axis.horizontal,
          children: [
            Container(
              width: 100,
              margin: const EdgeInsets.all(10.0),
              child: FloatingActionButton(
                heroTag: "1",
                backgroundColor: Colors.transparent,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) =>
                      PostUploader(postType: PostType.image,
                        user: widget.user,
                        category: widget.category,)));
                },
                child:
                const ImageIcon(AssetImage('assets/images/ttent.png'),
                  size: 600, color: Colors.red,
                ),
                // const Icon(Icons.camera_enhance),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
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
            title: Text(widget.category),
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                if (widget.user == null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) =>
                      VideoHomeScreen.forCategory(
                        category: widget.category,),),);
                }
                else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) =>
                      VideoHomeScreen.forUser(user: widget.user,)));
                }
              },
              icon: const Icon(Icons.play_circle_outlined, color:Colors.white),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: () async {
                  Share.share(
                      "Join me on TheGist: https://apps.apple.com/gb/app/thegistapp/id6451065035");
                },
                icon: const Icon(Icons.share, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => Search(postType: PostType.image,),),);
                },
                icon: const Icon(Icons.person_search, color:Colors.white),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) =>
                      UsersProfilePage(
                        userId: userIdx,
                        userName: name,
                        userImage: image,
                      )));
                },
                icon: const Icon(Icons.person, color:Colors.white),
              ),
              activityBadgeView,
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const SocialHomeScreen()));
                },
                icon: const Icon(Icons.message_sharp, color:Colors.white),
              )
            ]
        ),
        body: isLoadingList && postList.isEmpty ? const Center(child: CircularProgressIndicator()) :
              postList.isNotEmpty ? LazyLoadScrollView(
                        isLoading: isLoadingList,
                        onEndOfPage: () => getPicturePosts(),
                        child: PreloadPageView.builder(
                          physics: const BouncingScrollPhysics(),
                          preloadPagesCount: 5,
                          scrollDirection: Axis.vertical,
                          controller: PreloadPageController(initialPage: 0),
                          itemCount: postList.length,
                          itemBuilder: (BuildContext context, int index) {
                            Post post = postList[index];
                            classPost = post;

                            return pageViewWidget(
                                post.id,
                                post.source,
                                post.userImage,
                                post.userName,
                                post.createdAt,
                                post.email,
                                post.downloads,
                                post.viewCount,
                                post.postId,
                                post.likes,
                                post.viewers,
                                post.description,
                                post.downloaders);
                          },
                        )
                    ) :
              const Center(child: Text('Something went wrong', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),))
    );
  }

  Future<void> getPicturePosts() async {
    setState(() {
      isLoadingList = true;
    });

    if (firstLoad) {
      firstLoad = false;
      var posts = widget.user != null ? firestore.collection('wallpaper').where("id", isEqualTo: widget.user!.userId).limit(initialLoads) :
      widget.category == "random" ? firestore.collection('wallpaper').orderBy('viewcount', descending: true).limit(initialLoads) :
      firestore.collection('wallpaper').where("category", arrayContains: widget.category).limit(initialLoads);

      getPost(posts);
    }
    else {
      if (collectionState != null && collectionState!.docs.isNotEmpty) {
        var lastVisible = collectionState!.docs[collectionState!.docs.length - 1];
        var posts = widget.user != null ? firestore.collection('wallpaper').where("id", isEqualTo: widget.user!.userId).startAfterDocument(lastVisible).limit(nextLoads) :
        widget.category == "random" ? firestore.collection('wallpaper').orderBy('viewcount', descending: true).startAfterDocument(lastVisible).limit(nextLoads) :
        firestore.collection('wallpaper').where("category", arrayContains: widget.category).startAfterDocument(lastVisible).limit(nextLoads);

        getPost(posts);
      }
    }
  }

  void getPost(Query<Map<String, dynamic>> posts) {
    posts.get().then((value) {
      appendPosts(value);
      if (mounted) {
        setState(() {
          isLoadingList = false;
        });
      }
    });
  }

  void appendPosts(QuerySnapshot<Map<String, dynamic>> value) {
    collectionState = value;
    for (var element in value.docs) {
      Post post = Post.getPostSnapshot(element.data(), PostType.image);
      postList.add(post);
    }
  }
}

