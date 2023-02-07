import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Category {
  String category = "";
  List<String>? subCategory = List.empty(growable: true);

  Category({
    required this.category,
    required this.subCategory,
  });

  static Category getCategoryAsync(AsyncSnapshot <QuerySnapshot> snapshot, int index){
    return Category(category: snapshot.data?.docs[index]["category"],
        subCategory: List.from(snapshot.data!.docs[index]['subCategories'])
    );
  }

  static Category getCategory(QuerySnapshot snapshot, int index){
    return Category(category: snapshot.docs[index]["category"],
        subCategory: List.from(snapshot.docs[index]['subCategories'])
    );
  }

  Category.fromJson(Map<String, dynamic> json){
    category = json['category'];
    subCategory  = json['subCategories'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = category;
    data['subCategories'] = subCategory;

    return data;
  }
}