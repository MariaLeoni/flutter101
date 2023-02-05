import 'package:flutter/material.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'package:sharedstudent1/search_userpost/searchView.dart';
import 'home_screen/homescreen.dart';


class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => SearchState();
}

class SearchState extends State<Search> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(color: Colors.red,),
          actions: <Widget> [
            IconButton(
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(),),);
              },
              icon: const Icon(Icons.home, color: Colors.white,),
            ),
          ],
        ),

        body: ListView(
          children:[
            IconButton(iconSize: 50.0, onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SearchScreen(type: SearchType.post,),),);
              },
              icon: const Icon(Icons.search, color: Colors.black, ),
            ),
            const Center(child: Text('Search Post',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            )),
            const SizedBox( height: 50.0,),
            IconButton(iconSize: 50.0, onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SearchScreen(type: SearchType.user),),);
              },
              icon: const Icon(Icons.person_search, color: Colors.red,),
            ),
            const Center(child: Text('Search User',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            )),
          ],
        )
    );
  }
}
