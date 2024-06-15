import 'dart:developer';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geotagcameraapp/controller/tapcontroller.dart';
import 'package:get/get.dart';

class MytaskPage extends StatefulWidget {
  const MytaskPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MytaskPageState createState() => _MytaskPageState();
}

class _MytaskPageState extends State<MytaskPage> {
  bool isLoading = true; // Variable to track loading status

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GetxTapController controller = Get.put(GetxTapController());
    return WillPopScope(
      onWillPop: () async {
        if (controller.webViewController != null) {
          bool canGoBack = await controller.webViewController!.canGoBack();
          if (canGoBack) {
            controller.webViewController!.goBack();
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
                  onWebViewCreated: (controller2) {
                    controller.webViewController = controller2;
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
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var url = navigationAction.request.url.toString();

                    if (url == 'http://vety.cubeten.com/MV/mvlogin.aspx') {
                      context.router.replaceNamed('/');
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
                    setState(() {
                      isLoading = false; // Hide progress indicator
                    });
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      print('Loading complete');
                    }
                  },
                ),
                if (isLoading)
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
