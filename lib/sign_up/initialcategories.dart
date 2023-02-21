import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import '../home_screen/home.dart';
import '../misc/category.dart';
import '../misc/global.dart';
import '../widgets/button_square.dart';

class CategoryView1 extends StatefulWidget {

  InterestCallback interestCallback;
  bool isEditable = false;
  CategoryView1({super.key, required this.interestCallback, required this.isEditable});

  @override
  CategoryView1State createState() => CategoryView1State();
}

class CategoryView1State extends State<CategoryView1> with SingleTickerProviderStateMixin {
FirebaseAuth _auth = FirebaseAuth.instance;
  InterestCallback get interestCallback => widget.interestCallback;

  final FirebaseAuth auth = FirebaseAuth.instance;

  bool singleSelection = true;
  bool loaded = false;
  final int column = 0;
  final double fontSize = 16;
  final List icons = [Icons.home, Icons.language, Icons.headset];
  final GlobalKey<TagsState> categoryTagStateKey = GlobalKey<TagsState>();
  final GlobalKey<TagsState> subCategoryTagStateKey = GlobalKey<TagsState>();

  final List <Category> interestList = [];
  List<String>? categoryList = List.empty(growable: true);
  List<String>? subCategoryList = List.empty(growable: true);
  Map<String, List<String>?> catMap = {};

  Map<String, List<String>?> selectedInterests = {};
  Map<String, List<String>?> myInterests = {};
  List<String>? selectedSubInterests = List.empty(growable: true);
  String selectedInterest = "";

  Random random = Random();

  void loadInterests() async {
    FirebaseFirestore.instance.collection('Categories').get().then(
            (QuerySnapshot snapshot) => snapshot.docs.forEach((f) => {
          interestList.add(Category(category: f.get("category"),
              subCategory: List.from(f.get("subCategories")))),
          setState(() {
            interestList;
          })
        }));
  }

  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
      var data = jsonDecode(jsonEncode(snapshot.get('interests')));
      data.forEach((key, value) {
        List<String> subList = List.empty(growable: true);
        value.forEach((subCategory){
          subList.add(subCategory);
        });
        myInterests[key] = subList;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    readUserInfo();
    loadInterests();
  }

  @override
  Widget build(BuildContext context) {

    print("My interests ${myInterests}");

    if (interestList.isNotEmpty){
      if (!loaded){
        interestList.forEach((interest) {
          categoryList?.add(interest.category);
          catMap[interest.category] = interest.subCategory;
          setState(() {
            categoryList;
            loaded = true;
          });
        });
      }
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
            delegate: SliverChildListDelegate([
              const Padding(
                padding: EdgeInsets.all(20),
              ),
              categories,
              Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      const Divider(color: Colors.blueGrey,),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: (subCategoryList != null && subCategoryList!.isEmpty) ? const Text('Nothing Selected',
                           style: TextStyle(color: Colors.white, fontSize: 20.0,
                             fontWeight: FontWeight.bold,
                        )) : subCategories,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 8.0, right:8.0,),
                          child: ButtonSquare(
                              text:"Finish",
                              colors1: Colors.black,
                              colors2: Colors.black,

                              press: () async {
                                FirebaseFirestore.instance.collection('Interests')
                                    .doc(_auth.currentUser!.uid).set({'categories': selectedInterests});
                              }
                          )
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 8.0, right:8.0,),
                          child: ButtonSquare(
                              text:"Skip",
                              colors1: Colors.black,
                              colors2: Colors.black,

                              press: () async {

                                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> HomeScreen()));
                              }
                          )
                      )
                    ],
                  )),
            ])),
      ],
    );
  }

  Widget get categories {
    return Tags(
      key: categoryTagStateKey,
      symmetry: false,
      columns: column,
      horizontalScroll: false,
      heightHorizontalScroll: 60 * (fontSize / 14),
      itemCount: categoryList?.length,
      itemBuilder: (index) {
        final item = categoryList![index];
        return ItemTags(
            key: Key(index.toString()),
            index: index,
            title: item,
            pressEnabled: true,
            activeColor: Colors.blueGrey[600],
            singleItem: widget.isEditable ? false : true,
            splashColor: Colors.green,
            combine: ItemTagsCombine.withTextBefore,
            image:  null,
            icon: ItemTagsIcon(icon: icons[random.nextInt(3)]),
            textScaleFactor: utf8.encode(item.substring(0, 1)).length > 2 ? 0.8 : 1,
            textStyle: TextStyle(fontSize: fontSize),
            onPressed: (item) {
              if (selectedInterest != item.title){
                selectedInterest = item.title;
                selectedSubInterests = List.empty(growable: true);
              }

              setState(() {
                subCategoryList = catMap[item.title];
              });
            }
        );
      },
    );
  }

  Widget get subCategories {
    return Tags(
      key: subCategoryTagStateKey,
      symmetry: false,
      columns: column,
      horizontalScroll: false,
      heightHorizontalScroll: 60 * (fontSize / 14),
      itemCount: subCategoryList?.length,
      itemBuilder: (index) {
        final item = subCategoryList![index];

        return ItemTags(
            key: Key(index.toString()),
            index: index,
            title: item,
            active: false,
            pressEnabled: true,
            activeColor: Colors.blueGrey[600],
            singleItem: false,
            splashColor: Colors.green,
            combine: ItemTagsCombine.withTextBefore,
            image: null,
            icon: null,
            textScaleFactor: utf8.encode(item.substring(0, 1)).length > 2 ? 0.8 : 1,
            textStyle: TextStyle(fontSize: fontSize,),
            onPressed: (item) {
              if (!item.active){
                selectedSubInterests?.remove(item.title);
              }
              else if (selectedSubInterests != null && !selectedSubInterests!.contains(item.title)){
                selectedSubInterests?.add(item.title);
              }
              else{
                selectedSubInterests = List.empty(growable: true);
                selectedSubInterests!.add(item.title);
              }
              selectedInterests[selectedInterest] = selectedSubInterests;
              print("Selected interests $selectedInterests");
              interestCallback(selectedInterests);
            }
        );
      },
    );
  }
}