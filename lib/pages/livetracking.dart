import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LiveTrackingPage extends StatefulWidget {
  const LiveTrackingPage({super.key});

  @override
  _MytaskPageState createState() => _MytaskPageState();
}

class _MytaskPageState extends State<LiveTrackingPage> {
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
              onCloseWindow: (controller) {
                log('close');
                Navigator.of(context).pop();
              },
              initialUrlRequest: URLRequest(
                url: WebUri(
                  forceToStringRawValue: true,
                  'http://vety.cubeten.com/MV/ViewAll_Vehicle.html',
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
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  supportZoom: false,
                ),
              ),
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
