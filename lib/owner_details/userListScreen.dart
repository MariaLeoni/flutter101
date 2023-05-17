import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sharedstudent1/chat/constants.dart';
import 'package:sharedstudent1/chat/userModel.dart';
import '../chat/chatUsersProvider.dart';
import '../chat/chatWidgets.dart';
import '../log_in/login_screen.dart';
import '../misc/keyboardUtil.dart';
import '../misc/loadingView.dart';
import '../search_post/users_specifics_page.dart';

class UserListScreen extends StatefulWidget {
  List<String>? users;

  UserListScreen({super.key, this.users });

  @override
  State<UserListScreen> createState() => UserListScreenState();
}

class UserListScreenState extends State<UserListScreen> {
  final ScrollController scrollController = ScrollController();

  String searchText = "";
  bool isLoading = false;

  late String currentUserId;
  late ChatUsersProvider userListProvider;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  StreamController<bool> buttonClearController = StreamController<bool>();
  TextEditingController searchTextEditingController = TextEditingController();
  List<QueryDocumentSnapshot> documents = [];
  Stream? userList;

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
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

    userListProvider = ChatUsersProvider(firebaseFirestore: fireStore);

    scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace:Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.2, 0.9],
            ),
          ),
        ),
        title: const Text("Users"), centerTitle: true,
      ),
      body: Container(color:Colors.grey.shade900,
        child:Stack(
        children: [
          Column(
            children: [
              buildSearchBar(),
              Expanded(
                child: widget.users == null ? const Center(
                  child: Text('Looks like this list is empty',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),),
                 ) : StreamBuilder<QuerySnapshot>(
                  stream: userListProvider.getUsersIChatWith(FirestoreConstants.pathUserCollection, widget.users).snapshots(),
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
                          child: Text('Looks like this list is empty', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
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
      ),),
    );
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
      ChatUser userModel = ChatUser.fromDocument(documentSnapshot);
      return TextButton(
        onPressed: () {
          if (KeyboardUtils.isKeyboardShowing()) {
            KeyboardUtils.closeKeyboard(context);
          }
          Navigator.push(context, MaterialPageRoute(builder: (_) => UsersProfilePage(
            userId: userModel.id,
            userName: userModel.displayName,
            userImage: userModel.photoUrl,
          )));
        },
        child: ListTile(leading: userModel.photoUrl.isNotEmpty
            ? ClipRRect(borderRadius: BorderRadius.circular(Sizes.dimen_30),
          child: Image.network(userModel.photoUrl,
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
          title: Text(userModel.displayName,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}