import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tags/flutter_tags.dart';

class CategoryView extends StatefulWidget {

  const CategoryView({super.key});

  @override
  CategoryViewState createState() => CategoryViewState();
}

class CategoryViewState extends State<CategoryView> with SingleTickerProviderStateMixin {

  List<String>? campuses = List.empty(growable: true);
  String? memberuserId;
  FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool singleSelection = true;
  final int column = 0;
  final double fontSize = 16;
  final List icons = [Icons.home, Icons.language, Icons.headset];

  @override
  void initState() {
    super.initState();
  }


  final List _items4 = [
    'Christianity',
    'Islam',
    'Judaism',
    'Buddhism',
    'Hinduism',
    'Sikhism',
    'Astrology',
    'Atheism',
    'Zoroastrianism',
  ];
  final GlobalKey<TagsState> categoryTagStateKey = GlobalKey<TagsState>();

  @override
  Widget build(BuildContext context) {

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
                        children: const <Widget>[
                          Divider(color: Colors.blueGrey,),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('Nothing selected'),
                          ),
                        ],
                      )),
                ])),
          ],
        ));
  }

  Widget get categories {
    memberuserId = _auth.currentUser?.uid;

    return Tags(
      key: categoryTagStateKey,
      symmetry: false,
      columns: column,
      horizontalScroll: false,
      heightHorizontalScroll: 60 * (fontSize / 14),
      itemCount: _items4.length,
      itemBuilder: (index) {
        final item = _items4[index];

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
                ? ItemTagsIcon(
              icon: icons[int.parse(item)],
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