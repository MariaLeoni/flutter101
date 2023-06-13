import 'package:flutter/material.dart';
import 'package:sharedstudent1/misc/global.dart';
import 'package:sharedstudent1/search_userpost/searchView.dart';


class Search extends StatefulWidget {

  PostType? postType;
  Search({super.key, this.postType});
  @override

  State<Search> createState() => SearchState();
}

class SearchState extends State<Search> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(color: Colors.black,),
          actions: const <Widget> [
          ],
        ),body: Container( color:Colors.black,
    child:Center(child: ListView(
      shrinkWrap: true,
      children:[
           Center(child:IconButton(iconSize: 50.0, onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SearchScreen(type: SearchType.post,
                  postType: widget.postType,),),);
              },
              icon: const Icon(Icons.search, color: Colors.white, ),
            )),
            const Center(child: Text('Search Post',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )),
            const SizedBox( height: 50.0,),
          Center(child:  IconButton(iconSize: 50.0, onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SearchScreen(type: SearchType.user),),);
              },
              icon: const Icon(Icons.person_search, color: Colors.white,),
            )),
            const Center(child: Text('Search User',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )),
          ],
        )
    )
    ));
  }
}
