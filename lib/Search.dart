import 'package:flutter/material.dart';
import 'package:sharedstudent1/home_screen/h1.dart';
import 'package:sharedstudent1/search_post/search_post.dart';
import 'package:sharedstudent1/search_userpost/search_post.dart';


class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
          color: Colors.red,),
          actions: <Widget> [
          IconButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(),),);
            },

            icon: const Icon(Icons.home, color: Colors.black, ),
          ),
      ],
        ),

      body: ListView(
      children:[
      IconButton(
        iconSize: 50.0,
      onPressed: (){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SearchUserPost(),),);
    },

    icon: const Icon(Icons.search, color: Colors.black, ),
    ),
        Padding(
          padding: EdgeInsets.only(left: 120.0, right: 120.0,),
          child: Text(
            'Search Post',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    const SizedBox( height: 50.0,),
    IconButton(
      iconSize: 50.0,
    onPressed: (){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SearchPost(),),);
    },
    icon: const Icon(Icons.person_search, color: Colors.red,
    ),
    ),
        Padding(
          padding: EdgeInsets.only(left: 120.0, right: 120.0,),
        child: Text(
          'Search User ',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        )
      ],
      )
      ),
    );
  }
}
