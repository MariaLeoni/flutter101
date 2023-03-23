import 'package:flutter/material.dart';

import '../following/followers.dart';
import '../following/following.dart';

class NumbersWidget extends StatelessWidget {
  int? followersCount;
  int? followingCount;
  Text? followerText;
  List<String>? followers;
  List<String>? following;
  NumbersWidget({super.key,
    this.followersCount,
    this.followingCount,
    this.followerText,
    this.followers,
    this.following,
  });
  @override
  Widget build(BuildContext context) => Row(

    mainAxisAlignment: MainAxisAlignment.center,

    children: <Widget>[
      buildButton(context,followingCount.toString(), 'Following'),
      buildDivider(),
      buildButton(context, followersCount.toString(), 'Followers'),

    ],

  );
  Widget buildDivider() => Container(
    height: 24,
    child: VerticalDivider(),
  );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => Following(
            following: following,
            //followers: followers,
          )));
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}