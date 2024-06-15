import 'dart:convert';
import 'dart:developer';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geotagcameraapp/router/router.gr.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _MytaskPageState createState() => _MytaskPageState();
}

class _MytaskPageState extends State<LoginPage> {
  InAppWebViewController? webViewController;
  bool isLoading = true; // Variable to track loading status

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 201, 200, 200),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 0),
        child: Stack(
          children: [
            InAppWebView(
              preventGestureDelay: true,
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var url = navigationAction.request.url.toString();
                log("onclickbutton $url");
                if (url == 'http://vety.cubeten.com/MV/mv_task.aspx') {
                  context.router.replaceNamed('/navbar');
                  // Intercept the URL and navigate to a Flutter page instead
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const FlutterPage()),
                  // );
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
              initialUrlRequest: URLRequest(
                url: WebUri(
                  'http://vety.cubeten.com/MV/mvlogin.aspx',
                ),
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                // Load the font file as bytes

                setState(() {
                  isLoading = true; // Show progress indicator
                });
                print('Started loading: $url');
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  isLoading = false; // Hide progress indicator
                });
              },
              onLoadError: (controllerr, url, code, message) async {
                print('Error loading: $url, Error: $message');
                setState(() {
                  isLoading = false; // Hide progress indicator
                });
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  print('Loading complete');
                }
              },
              initialSettings: InAppWebViewSettings(supportZoom: false),
            ),
            if (isLoading)
              Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: const Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }
}
