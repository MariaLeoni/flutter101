import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/chat/constants.dart';
import 'package:sharedstudent1/chat/userModel.dart';
import '../home_screen/home.dart';
import '../log_in/login_screen.dart';
import '../misc/debouncer.dart';
import '../misc/keyboardUtil.dart';
import '../misc/loadingView.dart';
import '../profile/profile_screen.dart';
import 'chatScreen.dart';
import 'chatUsersProvider.dart';
import 'chatWidgets.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => ContactListScreenState();
}

class ContactListScreenState extends State<ContactListScreen> {
  final ScrollController scrollController = ScrollController();

  int _limit = 20;
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;

  late String currentUserId;
  late ChatUsersProvider chatUserProvider;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> buttonClearController = StreamController<bool>();
  TextEditingController searchTextEditingController = TextEditingController();

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

    scrollController.addListener(scrollListener);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade800,
            centerTitle: true,
            title: const Text('Search for User'),
            actions: [
              IconButton(
                  onPressed: (){
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()));
                   },
                  icon: const Icon(Icons.home)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  },
                  icon: const Icon(Icons.person)),
            ]),
        body: Container( color:Colors.grey.shade900,child:Stack(
          children: [
            Column(
              children: [
                buildSearchBar(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: chatUserProvider.getFirestoreData(FirestoreConstants.pathUserCollection, _limit, _textSearch),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if ((snapshot.data?.docs.length ?? 0) > 0) {
                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) => buildItem(
                                context, snapshot.data?.docs[index]),
                            controller: scrollController,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                            const Divider(),
                          );
                        } else {
                          return const Center(
                            child: Text('Search with a user...'),
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
    )
    ,);
  }

  Widget buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(Sizes.dimen_10),
      height: Sizes.dimen_50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.dimen_30),
        color: Colors.grey.shade700,
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
                    _textSearch = value;
                  });
                } else {
                  buttonClearController.add(false);
                  setState(() {
                    _textSearch = "";
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
                      _textSearch = '';
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
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}