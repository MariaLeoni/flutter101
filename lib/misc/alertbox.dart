import 'package:flutter/material.dart';

class FancyAlertDialog {

  static showFancyAlertDialog(BuildContext context,
      String title, String message, {
        required Icon icon,
        required String labelPositiveButton,
        required String labelNegativeButton,
        required VoidCallback onTapPositiveButton,
        required VoidCallback onTapNegativeButton,
      })
  {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4.0),
          ),
        ),
        child: Wrap(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.0),
                  topRight: Radius.circular(4.0),
                ),
                color:Colors.red,
              ),
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Stack(
                children: <Widget>[
                  Align(alignment: Alignment.topRight, child: icon,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 2.0,
                right: 16.0,
                bottom: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Text(title, style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.green),
                            padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(fontSize: 15, color: Colors.white)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),),
                          onPressed: onTapNegativeButton,
                          child: Text(
                            labelNegativeButton.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.grey),
                            padding:
                            MaterialStateProperty.all(const EdgeInsets.all(15)),
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(fontSize: 15, color: Colors.white)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                          ),
                          onPressed: onTapPositiveButton,
                          child: Text(
                            labelPositiveButton.toUpperCase(),
                            style: const TextStyle(color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}