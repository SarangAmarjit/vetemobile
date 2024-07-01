import 'dart:convert';
import 'dart:developer';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geotagcameraapp/controller/tapcontroller.dart';
import 'package:geotagcameraapp/pages/networkerrorpage.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
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
                  preventGestureDelay: true,
                  onCloseWindow: (controller) {
                    log('close');
                    Navigator.of(context).pop();
                  },
                  initialSettings: InAppWebViewSettings(
                    supportZoom: false,
                    javaScriptEnabled: true,
                    useHybridComposition: true,
                  ),
                  initialUrlRequest: URLRequest(
                    url: WebUri(
                      forceToStringRawValue: true,
                      'https://vetymanipur.in/MV/mv_task.aspx',
                    ),
                  ),
                  onWebViewCreated: (controller) {
                    getcontroller.webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    getcontroller.handleloadingpage(isloadingpage: true);
                    if (getcontroller.iscomingfromnavbar) {
                      log('ok donnnnnnn');
                    } else {
                      if (url.toString() ==
                          'https://vetymanipur.in/MV/mvlogin.aspx') {
                        context.router.replaceNamed('/login');
                      } else {
                        context.router.replaceNamed('/navbar');
                        getcontroller.handleinitialpage(iscomingnavbar: true);
                      }
                    }

                    print('Started loading: $url');
                  },
                  onLoadStop: (controller, url) async {
                    getcontroller.handleloadingpage(isloadingpage: false);

                    var elementValue = await controller.evaluateJavascript(
                        source:
                            "window.document.getElementById('ctl00_lbl_MVUno').innerText");
                    getcontroller.setusername(name: elementValue);
                    print('Value iddddd :$elementValue');
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var url = navigationAction.request.url.toString();
                    var uri = navigationAction.request.url;
                    if (uri != null && uri.scheme == "tel") {
                      await launch(uri.toString());
                      return NavigationActionPolicy.CANCEL;
                    }

                    if (url == 'https://vetymanipur.in/MV/mvlogout.aspx') {
                      context.router.replaceNamed('/logout');
                      return NavigationActionPolicy.CANCEL;
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadError: (controller, url, code, message) async {
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
