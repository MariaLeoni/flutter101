import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/Learn/learn.dart';
import 'package:sharedstudent1/home_screen/post.dart';
import 'package:sharedstudent1/log_in/login_screen.dart';
import 'package:sharedstudent1/owner_details/video_player.dart';
import '../message/sendmessage.dart';
import '../owner_details/owner_details.dart';
import '../profile/profile_screen.dart';
import '../search_post/search_post.dart';
import'package:uuid/uuid.dart';
import 'package:flutter/widgets.dart';



class  HomeScreen extends StatefulWidget {
String? docId;

HomeScreen({
  this.docId,
});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String changeTitle="Grid View";
  bool checkView =false;

  File? imageFile;
  File? videoFile;
  String? videoUrl;
  String? imageUrl;
  String? myImage;
  String? myName;
  String? docId;
  String postId = const Uuid().v4();
  final FirebaseAuth _auth = FirebaseAuth.instance;



  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(" Please choose an option"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _getFromCamera();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0,),
                        child: Icon(
                          Icons.camera,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(color: Colors.purple),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _getFromGallery();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0,),
                        child: Icon(
                            Icons.image,
                            color: Colors.purpleAccent
                        ),
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(color: Colors.purple),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  void _getFromCamera() async
  {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async
  {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage
      (sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

void _upload_image() async
    {
    if(imageFile == null) {
      Fluttertoast.showToast(msg: 'Please select an Image');
      return;
    }
    try
    {
      final ref = FirebaseStorage.instance.ref().child('userImages').child(DateTime.now().toString()+'jpg');
      await ref.putFile(imageFile!);
      imageUrl = await ref.getDownloadURL();

      FirebaseFirestore.instance.collection('wallpaper').doc(DateTime.now().toString()).set({
        'id': _auth.currentUser!.uid,
        'userImage': myImage,
        'name': myName,
        'email': _auth.currentUser!.email,
        'Image': imageUrl,
        'downloads': 0,
        'createdAt': DateTime.now(),
        'postId': postId,
        'likes': <String>[],
        'followers':<String>[],
      });

      Navigator.canPop(context) ? Navigator.pop(context) : null;
      imageFile = null;
    }

    catch(error)
  {
    Fluttertoast.showToast(msg: error.toString());
  }
}

void read_userInfo()async
{
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot)
    {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
    });
}
@override
  void initState() {
    super.initState();
    read_userInfo();
  }

  Widget listViewWidget (String docId, String img, String userImg, String name,
      DateTime date, String userId, int downloads, String postId, List<String>? likes) {
    return Padding(
      padding: const EdgeInsets.all (8.0),
      child: Card(
        elevation: 16.0,
        shadowColor: Colors.white10,
        child: Container(
            decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurple.shade300],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.2, 0.9],
          ),
        ),
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              GestureDetector(
                onTap:()
                    {

                      Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)  => OwnerDetails(
                        img: img,
                        userImg: userImg,
                        name: name,
                        date: date,
                        docId: docId,
                        userId: userId,
                        downloads: downloads,
                        postId: postId,
                        likes: likes,
                      )));
                    },
                child: Image.network(
                  img,
                  fit: BoxFit.cover,
                ) ,
              ),
              const SizedBox(height: 15.0,),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Row(
                  children:[
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        userImg,
                      ),
                    ),
                    const SizedBox(width: 10.0,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Text(
                          name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                        DateFormat("dd MMM, yyyy - hh:mn a").format(date).toString(),
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
      ),
    );
  }

  Widget gridViewWidget (String docId, String img, String userImg, String name,
      DateTime date, String userId, int downloads, String postId, List<String>? likes)
  {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(6.0),
      crossAxisSpacing: 1,
      crossAxisCount: 1,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurple.shade300],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.2, 0.9],
            ),
          ),
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap:()
            {
              print("go to ownerDetails  id $userId name $name");
              Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)  => OwnerDetails(
                img: img,
                userImg: userImg,
                name: name,
                date: date,
                docId: docId,
                userId: userId,
                downloads: downloads,
                postId: postId,
                likes: likes,
              )));
            },
            child: Center(
              child: Image.network(img, fit: BoxFit.fill,),
            ),
          ),

        ),
      ]
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.purple, Colors.deepPurple.shade300],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.2, 0.9],
      ),
    ),
    child: Scaffold(
      floatingActionButton: Wrap(
        direction: Axis.horizontal,
        children: [
          Container(
            margin: const EdgeInsets.all(10.0),
            child: FloatingActionButton(
              heroTag: "1",
              backgroundColor: Colors.deepPurple,
              onPressed: ()
                {
                  _showImageDialog();
                },
                child: const Icon(Icons.camera_enhance),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: FloatingActionButton(
              heroTag: "2",
              backgroundColor: Colors.purple,
              onPressed: ()
                {
                  _upload_image();
                },
                child: const Icon(Icons.cloud_upload)
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: FloatingActionButton(
              heroTag: "1",
              backgroundColor: Colors.deepPurple,
              onPressed: ()
              {
                _showImageDialog();
              },
              child: const Icon(Icons.video_camera_back_outlined),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        flexibleSpace:Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.2, 0.9],
            ),
          ),
        ),
        title: GestureDetector(
          onTap: ()
          {
            setState(()
            {
              changeTitle = "List View";
              checkView = true;
            });
          },
          onDoubleTap: ()
            {
              setState(() {
                changeTitle= "Grid View";
                checkView = false;
              });
            },
          child: Text(changeTitle),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: ()
          {
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
          },
          child: const Icon(
            Icons.login_outlined
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SearchPost(),),);
            },
            icon: const Icon(Icons.person_search),
          ),
          IconButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen(),),);
            },
            icon: const Icon(Icons.person),
          ),
           IconButton(
          onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Message(),),);
          },
          icon: const Icon(Icons.message_rounded),
           ),
          IconButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VideoApp(),),);
            },
            icon: const Icon(Icons.apartment),
          ),
        ]

      ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('wallpaper')
              .orderBy('createdAt',descending: true).snapshots(),
          builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot)
          {
            if(snapshot.connectionState == ConnectionState.waiting )
            {
              return Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.connectionState == ConnectionState.active)
            {
              if(snapshot.data!.docs.isNotEmpty){
                if(checkView == true)
                {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index)
                    {
                      Post post = Post.getPost(snapshot, index);

                      return listViewWidget(post.id, post.image, post.userImage,
                                           post.userName, post.createdAt, post.email,
                        post.downloads, post.postId, post.likes,);
                    },
                  );
                }
                else
                {
                  return GridView.builder(
                      itemCount: snapshot.data!.docs.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:3
                      ),
                      itemBuilder: (BuildContext context, int index)
                      {
                        Post post = Post.getPost(snapshot, index);

                        return gridViewWidget(post.id, post.image, post.userImage,
                          post.userName, post.createdAt, post.email,
                          post.downloads, post.postId, post.likes,);
                      }
                  );
                }
              }
              else{
                return const Center(
                    child: Text("There is no tasks",
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

    ),
    );

  }
}



