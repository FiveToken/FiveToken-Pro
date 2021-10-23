import 'package:fil/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  @override
  State<WebviewPage> createState() {
    return WebviewPageState();
  }
}

class WebviewPageState extends State<WebviewPage> {
  WebViewController controller;
  String url = '';
  String title = '';
  bool loaded = false;
  bool showWebview = false;
  @override
  void initState() {
    super.initState();
    var args = Get.arguments;
    if (args != null) {
      url = args['url'];
      title = args['title'];
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        showWebview = true;
      });
    });
    Future.delayed(Duration(seconds: 10)).then((value) {
      if (!loaded) {
        setState(() {
          loaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
        title: title,
        hasLeading: false,
        hasFooter: false,
        barColor: Colors.white,
        background: Colors.white,
        actions: [
          Center(
            child: Container(
              height: 30,
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  border: Border.all(color: CustomColor.grey),
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Row(
                children: [
                  GestureDetector(
                    child: Icon(
                      Icons.refresh,
                      color: Colors.black,
                    ),
                    onTap: () {
                      controller.reload();
                    },
                  ),
                  Container(
                    width: 1,
                    height: 18,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    color: CustomColor.grey,
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Get.back();
                    },
                  )
                ],
              ),
            ),
          )
        ],
        body: showWebview
            ? Stack(
                children: [
                  WebView(
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (c) {
                      controller = c;
                    },
                    onPageFinished: (str) {
                      setState(() {
                        loaded = true;
                      });
                    },
                    initialUrl: url,
                  ),
                  !loaded
                      ? Container(
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  CustomColor.primary),
                            ),
                          ),
                        )
                      : Container(),
                ],
              )
            : Container(
                color: Colors.white,
              ));
  }
}

void goWebviewPage({String url, String title = ''}) {
  Get.toNamed(webviewPage, arguments: {'title': title, 'url': url});
}
