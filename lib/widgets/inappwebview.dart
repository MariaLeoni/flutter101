import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../chat/chatWidgets.dart';
import '../misc/global.dart';
import '../misc/chromeSafari.dart';
import 'loadingDialog.dart';

class InAppWebViewPage extends StatefulWidget {
  final String url;
  final String title;

  final ChromeSafariBrowser browser = HMChromeSafariBrowser();

  InAppWebViewPage(this.url, this.title, {super.key});

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<InAppWebViewPage> {
  late InAppWebViewController? webViewController;
  final GlobalKey webViewKey = GlobalKey();
  double progress = 0;
  bool? isSecure;
  String url = '';
  String title = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
          title: Text(widget.title),
        ),
        body:
        Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),

                onWebViewCreated: (controller) async {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  if (url != null) {
                    setState(() {
                      this.url = url.toString();
                      isSecure = urlIsSecure(url);
                    });
                  }
                },
                onLoadStop: (controller, url) async {
                  if (url != null) {
                    setState(() {
                      this.url = url.toString();
                    });
                  }

                  final sslCertificate = await controller.getCertificate();
                  setState(() {
                    isSecure = sslCertificate != null || (url != null && urlIsSecure(url));
                  });
                },
                onUpdateVisitedHistory: (controller, url, isReload) {
                  if (url != null) {
                    setState(() {
                      this.url = url.toString();
                    });
                  }
                },
                onTitleChanged: (controller, title) {
                  if (title != null) {
                    setState(() {
                      this.title = title;
                    });
                  }
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final url = navigationAction.request.url;
                  if (navigationAction.isForMainFrame && url != null &&
                      !resourceSchemes.contains(url.scheme)) {
                    if (await canLaunchUrl(url)) {
                      launchUrl(url);
                      return NavigationActionPolicy.ALLOW;
                    }
                  }
                  print("url $url");
                  return NavigationActionPolicy.ALLOW;
                },
              ),
               progress < 1.0 ? getLoading() : Container(),
            ]
        )
    );
  }

  static bool urlIsSecure(Uri url) {
    return (url.scheme == "https") || isLocalizedContent(url);
  }

  static bool isLocalizedContent(Uri url) {
    return (url.scheme == "file" ||
        url.scheme == "chrome" ||
        url.scheme == "data" ||
        url.scheme == "javascript" ||
        url.scheme == "about");
  }
}