import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/chat/constants.dart';
import 'package:sharedstudent1/chat/contactListScreen.dart';
import 'package:sharedstudent1/chat/userModel.dart';
import '../log_in/login_screen.dart';
import '../misc/keyboardUtil.dart';
import '../misc/loadingView.dart';
import 'chatScreen.dart';
import 'chatUsersProvider.dart';
import 'chatWidgets.dart';

class ChatListScreen extends StatefulWidget {
  List<String> chatees = List.empty(growable: true);

  ChatListScreen({super.key, required this.chatees});

  @override
  State<ChatListScreen> createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen> {
  final ScrollController scrollController = ScrollController();

  int _limit = 20;
  final int _limitIncrement = 20;
  String searchText = "";
  bool isLoading = false;

  late String currentUserId;
  late ChatUsersProvider chatUserProvider;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  StreamController<bool> buttonClearController = StreamController<bool>();
  TextEditingController searchTextEditingController = TextEditingController();
  List<QueryDocumentSnapshot> documents = [];

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    buttonClearController.close();
  }

  @override
  void initState() {
    super.initState();

    if (_auth.currentUser == null){
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    currentUserId = _auth.currentUser!.uid;

    chatUserProvider = ChatUsersProvider(firebaseFirestore: fireStore);

    readUserInfo();

    scrollController.addListener(scrollListener);
  }

  readUserInfo() async {
    if (widget.chatees.isEmpty){
      fireStore.collection('users').doc(currentUserId).get()
          .then<dynamic>((DocumentSnapshot snapshot) {
        widget.chatees = List.from(snapshot.get('chatWith'));
        setState(() {
          widget.chatees;
          chatUserProvider = ChatUsersProvider(firebaseFirestore: fireStore);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Column(
            children: [
              buildSearchBar(),
              Expanded(
                child: widget.chatees.isEmpty ? const Center(
                  child: Text('You have not started any chat yet...'),
                ) : StreamBuilder<QuerySnapshot>(
                  stream: chatUserProvider.getUsersIChatWith(FirestoreConstants.pathUserCollection, widget.chatees).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      documents = snapshot.data!.docs;
                      if (searchText.isNotEmpty) {
                        documents = documents.where((user) {
                          return user.get(FirestoreConstants.displayName)
                              .toString()
                              .toLowerCase()
                              .contains(searchText.toLowerCase());
                        }).toList();
                      }

                      if (documents.isNotEmpty) {
                        return ListView.separated(
                          shrinkWrap: true,
                          itemCount: documents.length,
                          itemBuilder: (context, index) => buildItem(
                              context, documents[index]),
                          controller: scrollController,
                          separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                        );
                      } else {
                        return const Center(
                          child: Text('You have not started any chat yet...'),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          Positioned(
            child: isLoading ? const LoadingView() : const SizedBox.shrink(),
          ),
        ],
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactListScreen()));
              },
              child: const Icon(Icons.chat_bubble),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(Sizes.dimen_10),
      height: Sizes.dimen_50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.dimen_30),
        color: AppColors.greyColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: Sizes.dimen_10,
          ),
          const Icon(Icons.search,
            color: AppColors.white,
            size: Sizes.dimen_24,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchTextEditingController,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  buttonClearController.add(true);
                  setState(() {
                    searchText = value;
                  });
                } else {
                  buttonClearController.add(false);
                  setState(() {
                    searchText = "";
                  });
                }
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Search here...',
                hintStyle: TextStyle(color: AppColors.white),
              ),
            ),
          ),
          StreamBuilder(
              stream: buttonClearController.stream,
              builder: (context, snapshot) {
                return snapshot.data == true ? GestureDetector(onTap: () {
                  searchTextEditingController.clear();
                  buttonClearController.add(false);
                  setState(() {
                    searchText = '';
                  });
                },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 0,left: 16,right: 16),
                      child:Icon(Icons.clear_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    )) : const SizedBox.shrink();
              })
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
      if (userChat.id == currentUserId) {
        return const SizedBox.shrink();
      } else {
        return TextButton(
          onPressed: () {
            if (KeyboardUtils.isKeyboardShowing()) {
              KeyboardUtils.closeKeyboard(context);
            }
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => ChatScreen(
                  peerId: userChat.id,
                  peerAvatar: userChat.photoUrl,
                  peerNickname: userChat.displayName,
                  userAvatar: userChat.photoUrl,
                )));
          },
          child: ListTile(leading: userChat.photoUrl.isNotEmpty
              ? ClipRRect(borderRadius: BorderRadius.circular(Sizes.dimen_30),
            child: Image.network(userChat.photoUrl,
              fit: BoxFit.cover, width: 50, height: 50,
              loadingBuilder: (BuildContext ctx, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return SizedBox(width: 50, height: 50,
                    child: CircularProgressIndicator(color: Colors.grey,
                        value: loadingProgress.expectedTotalBytes !=
                            null ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null),
                  );
                }
              },
              errorBuilder: (context, object, stackTrace) {
                return const Icon(Icons.account_circle, size: 50);
              },
            ),
          )
              : const Icon(Icons.account_circle, size: 50,
          ),
            title: Text(userChat.displayName,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}