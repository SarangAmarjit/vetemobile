import 'dart:developer';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geotagcameraapp/controller/tapcontroller.dart';
import 'package:geotagcameraapp/pages/networkerrorpage.dart';
import 'package:get/get.dart';

class MytaskPage extends StatelessWidget {
  const MytaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    GetxTapController getcontroller = Get.put(GetxTapController());
    return WillPopScope(
      onWillPop: () async {
        if (getcontroller.webViewController != null) {
          bool canGoBack = await getcontroller.webViewController!.canGoBack();
          if (canGoBack) {
            getcontroller.webViewController!.goBack();
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 201, 200, 200),
        body: GetBuilder<GetxTapController>(builder: (_) {
          return SafeArea(
            minimum: const EdgeInsets.symmetric(vertical: 0),
            child: Stack(
              children: [
                InAppWebView(
                  // initialOptions: InAppWebViewGroupOptions(
                  //   crossPlatform: InAppWebViewOptions(
                  //     supportZoom: false,
                  //   ),
                  // ),
                  preventGestureDelay: true,
                  onCloseWindow: (controller) {
                    log('close');
                    Navigator.of(context).pop();
                  },
                  initialSettings: InAppWebViewSettings(supportZoom: false),
                  initialUrlRequest: URLRequest(
                    url: WebUri(
                      forceToStringRawValue: true,
                      'http://vety.cubeten.com/MV/mv_task.aspx',
                    ),
                  ),
                  onWebViewCreated: (controller) {
                    getcontroller.handleloadingpage(isloadingpage: true);
                    getcontroller.webViewController = controller;
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
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var url = navigationAction.request.url.toString();

                    if (url == 'http://vety.cubeten.com/MV/mvlogout.aspx') {
                      context.router.replaceNamed('/logout');
                      // Intercept the URL and navigate to a Flutter page instead
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const FlutterPage()),
                      // );
                      return NavigationActionPolicy.CANCEL;
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadError: (controllerr, url, code, message) async {
                    print('Error loading: $url, Error: $message');
                    getcontroller.handleloadingpage(isloadingpage: false);
                    getcontroller.handlenetworkpage(iserrorpage: true);
                  },
                  onLoadHttpError: (controller, url, statusCode, description) {
                    getcontroller.handleloadingpage(isloadingpage: false);
                    getcontroller.handlenetworkpage(iserrorpage: true);
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      print('Loading complete');
                    }
                  },
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
      ),
    );
  }
}
