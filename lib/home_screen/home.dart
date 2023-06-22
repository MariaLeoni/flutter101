import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:sharedstudent1/home_screen/videosHomescreen.dart';
import '../chat/socialHomeScreen.dart';
import 'picturesHomescreen.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  final int column = 0;
  final double fontSize = 16;
  final List activeColors = [Colors.lightBlueAccent, Colors.deepPurple,
    Colors.teal, Colors.indigo, Colors.orange, Colors.brown];
  final GlobalKey<TagsState> categoryTagStateKey = GlobalKey<TagsState>();

  final List<String>? myInterests = List.empty(growable: true);
  late List<String>? myChatees = List.empty(growable: true);
  String selectedInterest = "";

  Random random = Random();

  readUserInfo() async {
    fireStore.collection('users').doc(auth.currentUser!.uid).get()
        .then<dynamic>((DocumentSnapshot snapshot) {
          if (snapshot.data().toString().contains('interests')){
            var data = jsonDecode(jsonEncode(snapshot.get('interests')));
            data.forEach((key, value) {
              List<String> subList = List.empty(growable: true);
              value.forEach((subCategory){
                subList.add(subCategory);
              });
              myInterests?.addAll(subList);
            });
          }
      setState(() {
        myInterests;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    readUserInfo();
  }

  skip(){
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => PictureHomeScreen.forCategory(category: "random")));
  }
  @override
  Widget build(BuildContext context) {
    return (myInterests == null || myInterests!.isEmpty) ? PictureHomeScreen.forCategory(category: "random",) :
    Scaffold(
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
            title: const Text("Home"),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PictureHomeScreen.forCategory(category: "random")));
                },
                icon: const Icon(Icons.photo),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) =>
                      VideoHomeScreen.forCategory(category: "random"),),);
                },
                icon: const Icon(Icons.play_circle_outlined),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const SocialHomeScreen(),),);
                },
                icon: const Icon(Icons.message_sharp),
              )
            ]),
        body: Container(color:Colors.black,child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20.0,),
                  //const Text('These are your selected interests'),
                  const Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  categories,
                  SizedBox(height:20.0),
                  SizedBox( height: 300,
                      child:
                      OutlinedButton(
                        onPressed: skip,
                        child: const Text("skip", style:TextStyle(color:Colors.white, backgroundColor: Colors.red, fontSize: 30 )),
                      )),
                ])),
          ],
        )));
  }

  Widget get categories {
    return Tags(
      key: categoryTagStateKey,
      symmetry: false,
      columns: column,
      horizontalScroll: false,
      heightHorizontalScroll: 60 * (fontSize / 14),
      itemCount: myInterests!.length,
      itemBuilder: (index) {
        final item = myInterests![index];
        return ItemTags(
            key: Key(index.toString()),
            index: index,
            title: item,
            active: true,
            pressEnabled: true,
            activeColor: activeColors[random.nextInt(5)],
            singleItem: true,
            splashColor: Colors.green,
            combine: ItemTagsCombine.withTextBefore,
            image:  null,
            icon: null, //ItemTagsIcon(icon: icons[random.nextInt(3)]),
            textScaleFactor: utf8.encode(item.substring(0, 1)).length > 2 ? 0.8 : 1,
            textStyle: TextStyle(fontSize: fontSize),
            onPressed: (item) {
              selectedInterest = item.title!;
              Navigator.push(context, MaterialPageRoute(builder: (_) =>
                  PictureHomeScreen.forCategory(category: selectedInterest,)));
            }
        );
      },
    );
  }
}