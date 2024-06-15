import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  InAppWebViewController? webViewController;

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 201, 200, 200),
      body: SafeArea(
        child: SizedBox(
          child: InAppWebView(
            initialUrlRequest: URLRequest(
                url: WebUri('http://vety.cubeten.com/weblogin.aspx')),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var url = navigationAction.request.url.toString();
              log("onclickbutton $url");
              if (url == 'http://vety.cubeten.com/MV/mvlogin.aspx') {
                // Intercept the URL and navigate to a Flutter page instead
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const FlutterPage()),
                // );
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
            onLoadStart: (controller, url) {
              // print('Started loading: $url');
              //    if (url == 'http://vety.cubeten.com/weblogin.aspx') {
              //   // Intercept the URL and navigate to a Flutter page instead
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => const FlutterPage()),
              //   );
              //   return NavigationActionPolicy.CANCEL;
              // }
            },
            onLoadStop: (controller, url) async {
              print('Finished loading: $url');
            },
            onLoadError: (controller, url, code, message) {
              print('Error loading: $url, Error: $message');
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                print('Loading complete');
              }
            },
          ),
        ),
      ),
    );
  }
}
