import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sharedstudent1/chat/moodModel.dart';
import 'package:sharedstudent1/misc/progressIndicator.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'chatProvider.dart';
import 'chatWidgets.dart';
import 'constants.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'moodWidget.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({Key? key,}) : super(key: key);

  @override
  State<MoodScreen> createState() => MoodScreenState();
}

class MoodScreenState extends State<MoodScreen> {
  late String currentUserId;
  PostType? type = PostType.text;
  List<String> myFollowing = List.empty(growable: true);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  final PageController _pageController = PageController(initialPage: 0,
      keepPage: true);

  File? mediaFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";
  String myImageURL = "";
  String name = "";

  final TextEditingController textEditingController = TextEditingController();
  late ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = ChatProvider(firebaseFirestore: fireStore,
        firebaseStorage: firebaseStorage);

    currentUserId = _auth.currentUser!.uid;
    myFollowing.add(currentUserId);
    loadMe();
  }

  Future getImage(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      mediaFile = File(pickedFile.path);
      if (mediaFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile(PostType.image);
      }
    }
  }

  Future getVideo(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker.pickVideo(source: source);
    if (pickedFile != null) {
      mediaFile = File(pickedFile.path);
      if (mediaFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile(PostType.video);
      }
    }
  }

  void showAlert(){
    showGeneralDialog(barrierDismissible: true,
      barrierLabel: '', barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (ctx, anim1, anim2) => AlertDialog(
        title: const Text("What do you want to Mood?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Media from Gallery", style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 20, color: Colors.white, backgroundColor: Colors.lightBlueAccent),),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    getImage(ImageSource.gallery);
                    Navigator.pop(ctx);
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0,),
                        child: Icon(Icons.browse_gallery, color: Colors.red,),
                      ),
                      Text("Image", style: TextStyle(color: Colors.black),),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    getVideo(ImageSource.gallery);
                    Navigator.pop(ctx);
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0,),
                        child: Icon(Icons.image, color: Colors.redAccent,),
                      ),
                      Text("Video", style: TextStyle(color: Colors.black),),
                    ],
                  ),
                ),
              ],),
            const Divider(),
            const Text("Media from Camera", style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 20, color: Colors.white, backgroundColor: Colors.lightBlueAccent),),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      getImage(ImageSource.camera);
                      Navigator.pop(ctx);
                    },
                    child: const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(4.0,),
                          child: Icon(Icons.camera, color: Colors.red,),
                        ),
                        Text("Image", style: TextStyle(color: Colors.black),),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      getVideo(ImageSource.camera);
                      Navigator.pop(ctx);
                    },
                    child: const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(4.0,),
                          child: Icon(Icons.video_call, color: Colors.red,),
                        ),
                        Text("Video", style: TextStyle(color: Colors.black),),
                      ],
                    ),
                  ),
                ]),
            const Divider(),
            MaterialButton(onPressed: () {
              Navigator.pop(ctx);
              showTextPopAlert();
            }, child: const Text("Mood update", style: TextStyle(color: Colors.black),),)
          ],
        ),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      ),
      context: context,
    );
  }

  void showTextPopAlert(){
    showGeneralDialog(barrierDismissible: true,
      barrierLabel: '', barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (ctx, anim1, anim2) => AlertDialog(
        title: null,
        content: buildMessageInput(ctx),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      ),
      context: context,
    );
  }

  Future<bool> onBackPressed() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      chatProvider.updateFirestoreData(FirestoreConstants.pathUserCollection,
          currentUserId, {FirestoreConstants.chattingWith: null});
    }
    return Future.value(false);
  }

  Future loadMe() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(currentUserId).get().then((snapshot) {
      name = snapshot.data()![FirestoreConstants.displayName];
      myImageURL = snapshot.data()![FirestoreConstants.photoUrl];
      List<String> myFollowings = snapshot.data()!.toString().contains("following")
          ? List.from(snapshot.data()!['following']) : List.empty(growable: true);
      setState(() {
        myFollowing.addAll(myFollowings);
      });
    });
  }

  void uploadFile(PostType type) async {
    if (mediaFile == null){
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Sorry, media not found")));
      return;
    }
    LoadingIndicatorDialog().show(context);

    File uploadFile = File("");
    String extension = "";
    if (type == PostType.image){
      extension = ".jpg";
      uploadFile = mediaFile!;
    }
    else{
      extension = ".mp4";

      uploadFile = await getProcessedFile(mediaFile) ?? uploadFile;
    }

    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + extension;

    UploadTask uploadTask = chatProvider.uploadImageFile(mediaFile!, fileName, "moodMedia");

    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();

      String? thumbnail;
      if (type == PostType.video) {
        thumbnail = await VideoThumbnail.thumbnailFile(
            video: uploadFile.path,
            imageFormat: ImageFormat.PNG,
            quality: 100,
            maxWidth: 300,
            maxHeight: 300);

        uploadTask = chatProvider.uploadImageFile(File(thumbnail!), fileName, "moodMedia");
        snapshot = await uploadTask;
        thumbnail = await snapshot.ref.getDownloadURL();
      }
      else{
        thumbnail = imageUrl;
      }

      setState(() {
        isLoading = false;
        onSendMood(imageUrl, type);
        LoadingIndicatorDialog().dismiss();
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
        LoadingIndicatorDialog().dismiss();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? e.toString())));
    }
    catch(error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Hmm, something doesn't seem right")));

      setState(() {
        isLoading = false;
        LoadingIndicatorDialog().dismiss();
      });
    }
  }

  void onSendMood(String content, PostType type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMood(content, type, currentUserId, name, myImageURL);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Nothing to send")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.2, 0.9],
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: chatProvider.getMoods(),
            builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(),);
              }
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isNotEmpty) {
                  return PageView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    controller: _pageController,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return buildItem(context, snapshot.data!.docs[index]);
                    },
                  );
                }
                return const Center(
                  child: Text('Be the first to Mood...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),);
              } else {
                return const Center(
                  child: Text('Be the first to Mood...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),),);
              }
            },
          )
      ),
      floatingActionButton: Wrap(
        direction: Axis.horizontal,
        children: [
          Container(
            margin: const EdgeInsets.all(10.0),
            child: FloatingActionButton(
              heroTag: "1",
              backgroundColor: Colors.deepPurple,
              onPressed: () {
                showAlert();
              },
              child: const Icon(Icons.mood),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageInput(BuildContext ctx) {
    var screen = MediaQuery.of(context).size;
    return SizedBox(
        width: screen.width,
        height: 70,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.dimen_4, horizontal: Sizes.dimen_4),
            child:Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Sizes.dimen_20),
                color: AppColors.greyColor,
              ),
              child: Row(
                children: [
                  Flexible(child: TextField(
                    textInputAction: TextInputAction.send,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    controller: textEditingController,
                    decoration: const InputDecoration.collapsed(
                        hintText: "Your Mood...",
                        hintStyle: TextStyle(color: AppColors.white)),
                    onSubmitted: (value) {
                      onSendMood(textEditingController.text, PostType.text);
                      Navigator.pop(ctx);
                    },
                    style: const TextStyle(backgroundColor: AppColors.greyColor,
                        color: AppColors.white),
                  )),
                  Container(
                    margin: const EdgeInsets.only(left: Sizes.dimen_4),
                    decoration: BoxDecoration(
                      color: AppColors.greyColor,
                      borderRadius: BorderRadius.circular(Sizes.dimen_20),
                    ),
                    child: IconButton(
                      onPressed: () {
                        onSendMood(textEditingController.text, PostType.text);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.send_rounded),
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            )
        ));
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      MoodModel mood = MoodModel.fromDocument(documentSnapshot);
      return MoodWidget(moodModel: mood, context: context,);
    } else {
      return const SizedBox.shrink();
    }
  }

}