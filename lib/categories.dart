import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Categories {
  String? category;
  List<String>? subCategories= List.empty(growable: true);

  Categories({
    this. category,
    this.subCategories
  });

  static Categories getPost(AsyncSnapshot <QuerySnapshot> snapshot, int index){

    return Categories(
        category:snapshot.data!.docs[index]['category'] ,
        subCategories: List.from(snapshot.data!.docs[index]['subCategories'])
    );
  }
}