import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sharedstudent1/chat/fullImageView.dart';
import 'package:sharedstudent1/chat/moodModel.dart';
import 'package:sharedstudent1/misc/progressIndicator.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'chatProvider.dart';
import 'chatWidgets.dart';
import 'constants.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'fullScreenVideo.dart';

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

  int _limit = 20;
  final int _limitIncrement = 20;

  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";
  String myImageURL = "";
  String name = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  late ChatProvider chatProvider;
  List<QueryDocumentSnapshot> documents = [];

  @override
  void initState() {
    super.initState();
    chatProvider = ChatProvider(firebaseFirestore: fireStore,
        firebaseStorage: firebaseStorage);

    focusNode.addListener(onFocusChanged);
    scrollController.addListener(_scrollListener);

    currentUserId = _auth.currentUser!.uid;
    myFollowing.add(currentUserId);
    loadMe();
  }

  _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChanged() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  Future getImage(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
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
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
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
                  child: Row(
                    children: const [
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
                  child: Row(
                    children: const [
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
                    child: Row(
                      children: const [
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
                    child: Row(
                      children: const [
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

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
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
    LoadingIndicatorDialog().show(context);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadImageFile(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();

      String? thumbnail;
      if (type == PostType.video) {
        thumbnail = await VideoThumbnail.thumbnailFile(
            video: imageFile!.path,
            imageFormat: ImageFormat.PNG,
            quality: 100,
            maxWidth: 300,
            maxHeight: 300);

        uploadTask = chatProvider.uploadImageFile(File(thumbnail!), fileName);
        snapshot = await uploadTask;
        thumbnail = await snapshot.ref.getDownloadURL();
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
  }

  void onSendMood(String content, PostType type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMood(content, type, currentUserId);
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Nothing to send")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: StreamBuilder<QuerySnapshot>(
        stream: chatProvider.getMoods(myFollowing),
        builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }
          if (snapshot.hasData) {
            documents = snapshot.data!.docs;
            if (documents.isNotEmpty) {
              return ListView.separated(
                shrinkWrap: true,
                itemCount: documents.length,
                itemBuilder: (context, index) => buildItem(context, documents[index]),
                controller: scrollController,
                separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
              );
            }
            return const Center(
              child: Text('You have not moods yet...'),);
          } else {
            return const Center(
              child: Text('You have not moods yet...'),);
          }
        },
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
                    focusNode: focusNode,
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              mood.type == PostType.text.name
                  ? messageBubble(chatContent: mood.content,
                color: AppColors.spaceLight,
                textColor: AppColors.white,
                margin: const EdgeInsets.only(right: Sizes.dimen_10),)
                  : mood.type == PostType.image.name ? Container(
                margin: const EdgeInsets.only(
                    right: Sizes.dimen_10, top: Sizes.dimen_10),
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => FullImageView(url: mood.content))
                      );
                    },
                    child: chatImage(imageSrc: mood.content)
                ),
              ) : mood.type == PostType.video.name ? Container(
                margin: const EdgeInsets.only(
                    right: Sizes.dimen_10, top: Sizes.dimen_10),
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => FullScreenVideoView(url: mood.content))
                      );
                    },
                    child: chatVideoThumbnail(videoSrc: mood.content)
                ),
              ) : const SizedBox.shrink(),
              Container(clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Sizes.dimen_20),
                ),
                child: Image.network(myImageURL,
                  width: Sizes.dimen_40,
                  height: Sizes.dimen_40,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext ctx, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.burgundy,
                        value: loadingProgress.expectedTotalBytes !=
                            null &&
                            loadingProgress.expectedTotalBytes !=
                                null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, object, stackTrace) {
                    return const Icon(
                      Icons.account_circle,
                      size: 35,
                      color: AppColors.greyColor,
                    );
                  },
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(
                right: Sizes.dimen_50,
                top: Sizes.dimen_6,
                bottom: Sizes.dimen_8),
            child: Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                  int.parse(mood.timestamp),
                ),
              ),
              style: const TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: Sizes.dimen_12,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}