import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Category {
  String category = "";
  List<String>? subCategory = List.empty(growable: true);

  Category({
    required this.category,
    required this.subCategory,
  });

  static Category getCategory(AsyncSnapshot <QuerySnapshot> snapshot, int index){

    return Category(category: snapshot.data?.docs[index]["catorgy"],
        subCategory: List.from(snapshot.data!.docs[index]['subCategory'])
    );
  }
}