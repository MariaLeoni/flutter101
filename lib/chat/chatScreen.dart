import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sharedstudent1/chat/socialHomeScreen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import '../misc/global.dart';
import '../misc/progressIndicator.dart';
import '../notification/notification.dart';
import '../notification/server.dart';
import 'chatModel.dart';
import 'chatProvider.dart';
import 'chatWidgets.dart';
import 'constants.dart';
import 'fullImageView.dart';
import 'fullScreenVideo.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;
  final String userAvatar;

  const ChatScreen({Key? key,
    required this.peerNickname,
    required this.peerAvatar,
    required this.peerId,
    required this.userAvatar}) : super(key: key);

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late String currentUserId;
  PostType? type = PostType.text;
  List<QueryDocumentSnapshot> listMessages = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  NotificationManager? notificationManager;
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId = '';

  File? mediaFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";
  String myImageURL = "";
  String name = "";
  String? tokens;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  late ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = ChatProvider(firebaseFirestore: fireStore,
        firebaseStorage: firebaseStorage);

    focusNode.addListener(onFocusChanged);
    scrollController.addListener(_scrollListener);

    currentUserId = _auth.currentUser!.uid;
    loadMe();
    readLocal();
    getDataFromDatabase2();
    notificationManager = NotificationManager();
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

  void readLocal() {
    if (currentUserId.compareTo(widget.peerId) > 0) {
      groupChatId = '$currentUserId - ${widget.peerId}';
    } else {
      groupChatId = '${widget.peerId} - $currentUserId';
    }
    chatProvider.updateFirestoreData(FirestoreConstants.pathUserCollection,
        currentUserId, {FirestoreConstants.chattingWith: widget.peerId});

  }


  Future getImage(ImageSource source) async {
    if(source == ImageSource.camera) {
      await requestPermission(Permission.camera, (permissionStatus) async{
        if (permissionGranted(permissionStatus)){
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
        else{
          openAppSettings();
        }
      });
    }
    else{
      await requestPermission(Permission.storage, (permissionStatus) async {
        if (permissionGranted(permissionStatus)) {
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
        else{
          openAppSettings();
        }
      });
    }
  }

  Future getVideo(ImageSource source) async {
    if(source == ImageSource.camera) {
      await requestPermission(Permission.camera, (permissionStatus) async{
        if (permissionGranted(permissionStatus)){
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
        else{
          openAppSettings();
        }
      });
    }
    else{
      await requestPermission(Permission.storage, (permissionStatus) async {
        if (permissionGranted(permissionStatus)) {
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
        else{
          openAppSettings();
        }
      });
    }
  }

  void showAlert(){
    showGeneralDialog(barrierDismissible: true,
      barrierLabel: '', barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (ctx, anim1, anim2) => AlertDialog(
        title: const Text("Please choose an option"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
                  Text("Image from Camera", style: TextStyle(color: Colors.black),),
                ],
              ),
            ),
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
                  Text("Image from Gallery", style: TextStyle(color: Colors.black),),
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
                  Text("Video from Camera", style: TextStyle(color: Colors.black),),
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
                  Text("Video from Gallery", style: TextStyle(color: Colors.black),),
                ],
              ),
            ),
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
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async { if (snapshot.exists) {
      setState(() {
        name = snapshot.data()![FirestoreConstants.displayName];
        myImageURL = snapshot.data()![FirestoreConstants.photoUrl];
      });
    }
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
    UploadTask uploadTask = chatProvider.uploadImageFile(uploadFile, fileName, "chatMedia");
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();

      String? thumbnail;

      if (type == PostType.image) {
        thumbnail = imageUrl;
      }
      else {
        thumbnail = await VideoThumbnail.thumbnailFile(
            video: uploadFile.path,
            imageFormat: ImageFormat.PNG,
            quality: 100,
            maxWidth: 300,
            maxHeight: 300);
        fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

        uploadTask = chatProvider.uploadImageFile(File(thumbnail!), fileName, "chatMedia");
        snapshot = await uploadTask;
        thumbnail = await snapshot.ref.getDownloadURL();
      }

      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, type, thumbnail);
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

      print("Chat upload error $error");
      setState(() {
        isLoading = false;
        LoadingIndicatorDialog().dismiss();
      });
    }
  }

  void getDataFromDatabase2() async {
    await FirebaseFirestore.instance.collection("users")
        .doc(widget.peerId)
        .get()
        .then((snapshot) async { if (snapshot.exists) {
      setState(() {
        tokens = snapshot.data()!["token"];
      });
    }
    });
  }

  void sendNotification(String action) {
    NotificationModel model = NotificationModel(title: name,
      body: action,

    );
    String? token = tokens;
    notificationManager?.sendNotification(token!, model);
  }

  void onSendMessage(String content, PostType type, String? thumbnail) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendChatMessage(content, type, groupChatId, currentUserId,
          widget.peerId, thumbnail);
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      sendNotification(content);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Nothing to send")));
    }
  }

  // checking if received message
  bool isMessageReceived(int index) {
    if ((index > 0 && listMessages[index - 1].get(FirestoreConstants.idFrom) ==
        currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // checking if sent message
  bool isMessageSent(int index) {
    if ((index > 0 && listMessages[index - 1].get(FirestoreConstants.idFrom) !=
        currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade900,
          centerTitle: true,
          title: Text('Chatting with ${widget.peerNickname}'.trim()),
          leading: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const SocialHomeScreen(),),);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          actions: const [

          ],
        ),
        body: Container( color: Colors.grey.shade800,child:SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.dimen_8),
            child: Column(
              children: [
                buildListMessage(),
                buildMessageInput(),
              ],
            ),
          ),
        ),
        ));
  }

  Widget buildMessageInput() {
    var screen = MediaQuery.of(context).size;
    return SizedBox(width: screen.width, height: 70,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.dimen_8),
            child:Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Sizes.dimen_30),
                color: Colors.grey.shade700,
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: Sizes.dimen_4),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(Sizes.dimen_20),
                    ),
                    child: IconButton(
                      onPressed: showAlert,
                      icon: const Icon(Icons.add_a_photo, size: Sizes.dimen_18,
                      ),
                      color: AppColors.white,
                    ),
                  ),
                  Flexible(child: TextField(
                    focusNode: focusNode,
                    textInputAction: TextInputAction.send,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    controller: textEditingController,
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Type here...',
                        hintStyle: TextStyle(color: AppColors.white)),
                    onSubmitted: (value) {
                      onSendMessage(textEditingController.text, PostType.text, "");
                    },
                    style: const TextStyle(backgroundColor: Colors.transparent,
                        color: AppColors.white),
                  )),
                  Container(
                    margin: const EdgeInsets.only(left: Sizes.dimen_4),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(Sizes.dimen_20),
                    ),
                    child: IconButton(
                      onPressed: () {
                        onSendMessage(textEditingController.text, PostType.text, "");
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

  Widget buildItem(int index, DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      ChatMessages chatMessages = ChatMessages.fromDocument(documentSnapshot);
      if (chatMessages.idFrom == currentUserId) {
        // right side (my message)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                chatMessages.type == PostType.text.name
                    ? messageBubble(chatContent: chatMessages.content,
                  color: AppColors.spaceLight,
                  textColor: AppColors.white,
                  margin: const EdgeInsets.only(right: Sizes.dimen_10, bottom: 5),)
                    : chatMessages.type == PostType.image.name ? Container(
                  margin: const EdgeInsets.only(
                    right: Sizes.dimen_10, top: Sizes.dimen_10, ),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => FullImageView(url: chatMessages.content))
                        );
                      },
                      child: chatImage(imageSrc: chatMessages.content)
                  ),
                ) : chatMessages.type == PostType.video.name ? Container(
                  margin: const EdgeInsets.only(
                      right: Sizes.dimen_10, top: Sizes.dimen_10),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => FullScreenVideoView(url: chatMessages.content))
                        );
                      },
                      child: chatVideoThumbnail(videoSrc: chatMessages.thumbnail!)
                  ),
                ) : const SizedBox.shrink(),
                isMessageSent(index) ? Container(clipBehavior: Clip.hardEdge,
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
                              loadingProgress.expectedTotalBytes! : null,
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
                ) : Container(width: 35,),
              ],
            ),
            isMessageSent(index) ? Container(
              margin: const EdgeInsets.only(
                  right: Sizes.dimen_50,
                  top: Sizes.dimen_6,
                  bottom: Sizes.dimen_8),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(chatMessages.timestamp),
                  ),
                ),
                style: const TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: Sizes.dimen_12,
                    fontStyle: FontStyle.italic),
              ),
            ) : const SizedBox.shrink(),
          ],
        );
      } else {
        // left side (others message)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                isMessageReceived(index)
                // left side (received message)
                    ? Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Sizes.dimen_20),
                  ),
                  child: Image.network(
                    widget.peerAvatar,
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
                ) : Container(width: 35,),
                chatMessages.type == PostType.text.name
                    ? messageBubble(color: AppColors.burgundy, textColor: AppColors.white,
                  chatContent: chatMessages.content,
                  margin: const EdgeInsets.only(left: Sizes.dimen_10),
                ) : chatMessages.type == PostType.image.name
                    ? Container(
                  margin: const EdgeInsets.only(
                      left: Sizes.dimen_10, top: Sizes.dimen_10),
                  child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => FullImageView(url: chatMessages.content))
                        );
                      },
                      child:
                      chatImage(imageSrc: chatMessages.content)
                  ),
                ) : chatMessages.type == PostType.video.name ? Container(
                  margin: const EdgeInsets.only(
                      right: Sizes.dimen_10, top: Sizes.dimen_10),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => FullScreenVideoView(url: chatMessages.content))
                        );
                      },
                      child: chatVideoThumbnail(videoSrc: chatMessages.thumbnail!)
                  ),
                ): const SizedBox.shrink(),
              ],
            ),
            isMessageReceived(index)
                ? Container(
              margin: const EdgeInsets.only(
                  left: Sizes.dimen_50,
                  top: Sizes.dimen_6,
                  bottom: Sizes.dimen_8),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(chatMessages.timestamp),
                  ),
                ),
                style: const TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: Sizes.dimen_12,
                    fontStyle: FontStyle.italic),
              ),
            ) : const SizedBox.shrink(),
          ],
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
          stream: chatProvider.getChatMessage(groupChatId, _limit),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              listMessages = snapshot.data!.docs;
              if (listMessages.isNotEmpty) {
                return ListView.builder(
                    padding: const EdgeInsets.only(top:17, bottom:17, left:20 ,right:20),
                    itemCount: snapshot.data?.docs.length,
                    reverse: true,
                    controller: scrollController,
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data?.docs[index]));
              } else {
                return const Center(
                  child: Text('No messages...'),
                );
              }
            } else {
              return const Center(child: CircularProgressIndicator(
                color: AppColors.burgundy,
              ),
              );
            }
          })
          : const Center(child: CircularProgressIndicator(
        color: AppColors.burgundy,
      ),
      ),
    );
  }
}