import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class _SystemPadding extends StatelessWidget {
  final Widget child;

  const _SystemPadding({required Key key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}

// void read() async {
//   FirebaseFirestore.instance.collection('comment').where("postId", isEqualTo: widget.postId)
//       .get().then(
//         (res) => res.docs.forEach((element) {
//           print("Successfully fetched: ${element.get("comment")}");
//         }),
//         onError: (e) => print("Error completing: $e"),
//   );
// }