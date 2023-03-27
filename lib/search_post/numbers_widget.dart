import 'package:flutter/material.dart';
import 'package:sharedstudent1/misc/global.dart';

import '../following/follows.dart';
import '../widgets/widgets.dart';

class NumbersWidget extends StatelessWidget {

  List<String>? followers = List.empty(growable: true);
  List<String>? following = List.empty(growable: true);
  String userName = "";

  NumbersWidget({super.key, required this.following, required this.followers, required this.userName});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      buildButton(context, following, FFType.following),
      buildDivider(),
      buildButton(context, followers, FFType.follower),
    ],
  );

  Widget buildButton(BuildContext context, List<String>? users, FFType type){
    String text = "";
    if (type == FFType.following){
      text = following == null ? "Following" :  following!.length > 1 ? 'Followings': 'Following';
    }
    else{
      text = followers == null ? 'Follower' : followers!.length > 1 ? 'Followers' : 'Follower';
    }
    return MaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 4),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => Follows(follow: users, user: userName, type: type,),),);
      },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(getString(users),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 2), Text(text, style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String getString(List<String>? users){
    String returned = "0";
    if (users == null) {
      return returned;
    } else {
      return users.length.toString();
    }
  }
}