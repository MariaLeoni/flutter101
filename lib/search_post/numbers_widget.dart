import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class NumbersWidget extends StatelessWidget {

  int following = 0;
  int followers = 0;

  NumbersWidget({super.key, required this.following, required this.followers});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      buildButton(context, following, following > 1 ? 'Followings': 'Following'),
      buildDivider(),
      buildButton(context, followers, followers > 1 ? 'Followers' : 'Follower'),
    ],
  );

  Widget buildButton(BuildContext context, int value, String text) =>
      MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 2), Text(text, style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}