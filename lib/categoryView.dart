import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'misc/category.dart';
import 'misc/global.dart';

class CategoryView extends StatefulWidget {

  InterestCallback interestCallback;
  bool isEditable = false;
  CategoryView({super.key, required this.interestCallback, required this.isEditable});

  @override
  CategoryViewState createState() => CategoryViewState();
}

class CategoryViewState extends State<CategoryView> with SingleTickerProviderStateMixin {

  InterestCallback get interestCallback => widget.interestCallback;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  final ValueNotifier<List<String>?> subCategoryList = ValueNotifier<List<String>?>([]);

  bool singleSelection = true;
  bool loaded = false;
  final int column = 0;
  final double fontSize = 16;
  final List icons = [Icons.home, Icons.language, Icons.headset];
  final List activeColors = [Colors.lightBlueAccent, Colors.deepPurple,
                            Colors.teal, Colors.indigo, Colors.orange, Colors.brown];
  final GlobalKey<TagsState> categoryTagStateKey = GlobalKey<TagsState>();
  final GlobalKey<TagsState> subCategoryTagStateKey = GlobalKey<TagsState>();

  final List <Category> interestList = [];
  final List<String>? categoryList = List.empty(growable: true);
  Map<String, List<String>?> catMap = {};

  Map<String, List<String>?> selectedInterests = {};
  Map<String, List<String>?> myInterests = {};
  List<String>? selectedSubInterests = List.empty(growable: true);
  String selectedInterest = "";

  Random random = Random();

  loadInterests() async {
    fireStore.collection('Categories').get().then(
            (QuerySnapshot snapshot) => snapshot.docs.forEach((f) => {
          interestList.add(Category(category: f.get("category"),
              subCategory: List.from(f.get("subCategories")))),
          setState(() {
            interestList;
          })
        })
    );
  }

  readUserInfo() async {
    fireStore.collection('users').doc(auth.currentUser!.uid).get()
        .then<dynamic>((DocumentSnapshot snapshot) {
      var data = jsonDecode(jsonEncode(snapshot.get('interests')));
      data.forEach((key, value) {
        List<String> subList = List.empty(growable: true);
        value.forEach((subCategory){
          subList.add(subCategory);
        });
        myInterests[key] = subList;
      });
      setState(() {
        selectedInterests = myInterests;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    loadInterests();
    readUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    if (interestList.isNotEmpty){
      if (!loaded){
        interestList.forEach((interest) {
          categoryList?.add(interest.category);
          catMap[interest.category] = interest.subCategory;
          loaded = true;
          setState(() {
            categoryList;
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
                          child: ValueListenableBuilder<List<String>?>(
                              valueListenable: subCategoryList,
                              builder: (context, value, _) {
                                return subCategoryList.value == null ? const Text('Nothing selected') :
                                  subCategories;})
                      ),
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
      itemCount: categoryList!.length,
      itemBuilder: (index) {
        final item = categoryList![index];
        return ItemTags(
            key: Key(index.toString()),
            index: index,
            title: item,
            active: selectedInterests.keys.contains(item) ? true : false,
            pressEnabled: true,
            activeColor: activeColors[random.nextInt(5)],
            singleItem: false,
            splashColor: Colors.green,
            combine: ItemTagsCombine.withTextBefore,
            image:  null,
            icon: null, //ItemTagsIcon(icon: icons[random.nextInt(3)]),
            textScaleFactor: utf8.encode(item.substring(0, 1)).length > 2 ? 0.8 : 1,
            textStyle: TextStyle(fontSize: fontSize),
            onPressed: (item) {
              if (!item.active! && selectedInterests.keys.contains(item.title)){
                subCategoryList.value = catMap[item.title];
              }
              if (!item.active! && !selectedInterests.keys.contains(item.title)){
                subCategoryList.value = null;
                selectedInterests.remove(item.title);
              }
              else{
                if (selectedInterest != item.title){
                  selectedInterest = item.title!;
                  selectedSubInterests = List.empty(growable: true);
                }
                subCategoryList.value = catMap[item.title];
              }
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
      itemCount: subCategoryList.value!.length,
      itemBuilder: (index) {
        final item = subCategoryList.value?[index];

        return ItemTags(
            key: Key(index.toString()),
            index: index,
            title: item!,
            active: selectedInterests[selectedInterest] == null ? false : selectedInterests[selectedInterest]!.contains(item) ? true : false,
            pressEnabled: true,
            activeColor: activeColors[random.nextInt(5)],
            singleItem: false,
            splashColor: Colors.green,
            combine: ItemTagsCombine.withTextBefore,
            image: null,
            icon: null,
            textScaleFactor: utf8.encode(item.substring(0, 1)).length > 2 ? 0.8 : 1,
            textStyle: TextStyle(fontSize: fontSize,),
            onPressed: (item) {
              if (!item.active!){
                selectedSubInterests?.remove(item.title);
              }
              else if (selectedSubInterests != null && !selectedSubInterests!.contains(item.title)){
                selectedSubInterests?.add(item.title!);
              }
              else{
                selectedSubInterests = List.empty(growable: true);
                selectedSubInterests!.add(item.title!);
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