import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tags/flutter_tags.dart';

import 'misc/category.dart';

class CategoryView extends StatefulWidget {

  const CategoryView({super.key});

  @override
  CategoryViewState createState() => CategoryViewState();
}

class CategoryViewState extends State<CategoryView> with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  bool singleSelection = true;
  bool loaded = false;
  final int column = 0;
  final double fontSize = 16;
  final List icons = [Icons.home, Icons.language, Icons.headset];

  final List <Category> interestList = [];
  List<String>? categoryList = List.empty(growable: true);
  List<String>? subCategoryList = List.empty(growable: true);
  Map<String, List<String>?> catMap = {};

  void readUserInfo() async {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then<dynamic>((DocumentSnapshot snapshot) {
    });

    FirebaseFirestore.instance.collection('Categories').get().then(
            (QuerySnapshot snapshot) => snapshot.docs.forEach((f) => {
              interestList.add(Category(category: f.get("category"),
              subCategory: List.from(f.get("subCategories")))),
          setState(() {
            interestList;
          })
        }));
  }

  @override
  void initState() {
    super.initState();

    readUserInfo();
  }

  final GlobalKey<TagsState> categoryTagStateKey = GlobalKey<TagsState>();
  final GlobalKey<TagsState> subCategoryTagStateKey = GlobalKey<TagsState>();

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
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
          title: const Text("Post"),
        ),
        body: CustomScrollView(
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
                            child: (subCategoryList != null && subCategoryList!.isEmpty) ? const Text('Nothing selected') : subCategories,
                          ),
                        ],
                      )),
                ])),
          ],
        ));
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
            singleItem: true,
            splashColor: Colors.green,
            combine: ItemTagsCombine.withTextBefore,
            image: index > 0 && index < 5
                ? ItemTagsImage(child: Image.network(
              "http://www.clipartpanda.com/clipart_images/user-66327738/download",
              width: 16 * fontSize / 14,
              height: 16 * fontSize / 14,
            ))
                : (1 == 1
                ? ItemTagsImage(
              image: const NetworkImage(
                  "https://d32ogoqmya1dw8.cloudfront.net/images/serc/empty_user_icon_256.v2.png"),
            )
                : null),
            icon: (item == '0' || item == '1' || item == '2')
                ? ItemTagsIcon(icon: icons[int.parse(item)],
            )
                : null,
            textScaleFactor: utf8.encode(item.substring(0, 1)).length > 2 ? 0.8 : 1,
            textStyle: TextStyle(fontSize: fontSize,
            ),
            onPressed: (item) {
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
            pressEnabled: true,
            activeColor: Colors.blueGrey[600],
            singleItem: false,
            splashColor: Colors.green,
            combine: ItemTagsCombine.withTextBefore,
            image: index > 0 && index < 5
                ? ItemTagsImage(child: Image.network(
              "http://www.clipartpanda.com/clipart_images/user-66327738/download",
              width: 16 * fontSize / 14,
              height: 16 * fontSize / 14,
            ))
                : (1 == 1
                ? ItemTagsImage(
              image: const NetworkImage(
                  "https://d32ogoqmya1dw8.cloudfront.net/images/serc/empty_user_icon_256.v2.png"),
            )
                : null),
            icon: (item == '0' || item == '1' || item == '2')
                ? ItemTagsIcon(icon: icons[int.parse(item)],
            )
                : null,
            textScaleFactor: utf8.encode(item.substring(0, 1)).length > 2 ? 0.8 : 1,
            textStyle: TextStyle(fontSize: fontSize,
            ),
            onPressed: (item) {
              //Handle on press here
              // List<String> interest = List.empty(growable: true);
              // for (var element in _items) {
              //   interest.add(element.toString());
              // }
              // FirebaseFirestore.instance.collection('tags').doc(memberuserId).set({
              //   "tagName": interest,
              // });
            }
          //> print(item),
        );
      },
    );
  }
}