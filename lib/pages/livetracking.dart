import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geotagcameraapp/controller/tapcontroller.dart';
import 'package:get/get.dart';

class LiveTrackingPage extends StatelessWidget {
  LiveTrackingPage({super.key});

  InAppWebViewController? webViewController;

  // Variable to track loading status
  @override
  Widget build(BuildContext context) {
    GetxTapController getcontroller = Get.put(GetxTapController());

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 201, 200, 200),
      body: GetBuilder<GetxTapController>(builder: (_) {
        return SafeArea(
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
                onReceivedError: (controller, request, error) {
                  getcontroller.handlenetworkpage(iserrorpage: true);
                },
                onLoadStart: (controller, url) {
                  // Load the font file as bytes

                  getcontroller.handleloadingpage(isloadingpage: true);

                  print('Started loading: $url');
                },
                onLoadStop: (controller, url) async {
                  getcontroller.handleloadingpage(isloadingpage: false);
                },
                onLoadError: (controllerr, url, code, message) async {
                  print('Error loading: $url, Error: $message');
                  getcontroller.handleloadingpage(isloadingpage: false);
                  getcontroller.handlenetworkpage(iserrorpage: true);
                },
                onReceivedHttpError: (controller, request, errorResponse) {
                  getcontroller.handleloadingpage(isloadingpage: false);
                  getcontroller.handlenetworkpage(iserrorpage: true);
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
              if (getcontroller.isLoading)
                Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: const Center(child: CircularProgressIndicator())),
            ],
          ),
        );
      }),
    );
  }
}
