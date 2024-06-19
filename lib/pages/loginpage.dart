import 'dart:convert';
import 'dart:developer';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geotagcameraapp/controller/tapcontroller.dart';
import 'package:geotagcameraapp/pages/networkerrorpage.dart';
import 'package:geotagcameraapp/router/router.gr.dart';
import 'package:get/get.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  InAppWebViewController? webViewController;

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
              getcontroller.isErrorPageDisplayed
                  ? const NetworkErrorPage()
                  : InAppWebView(
                      preventGestureDelay: true,
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        var url = navigationAction.request.url.toString();
                        log("onclickbutton $url");
                        if (url == 'http://vety.cubeten.com/MV/mv_task.aspx') {
                          getcontroller.handleloadingpage(isloadingpage: true);
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
                      onReceivedError: (controller, request, error) {
                        getcontroller.handlenetworkpage(iserrorpage: true);
                      },
                      initialUrlRequest: URLRequest(
                        url: WebUri(
                          'http://vety.cubeten.com/MV/mvlogin.aspx',
                        ),
                      ),
                      onWebViewCreated: (controller) {
                        log('onweb......');
                        getcontroller.handleloadingpage(isloadingpage: true);
                        webViewController = controller;
                      },
                      onPageCommitVisible: (controller, url) async {
                        ByteData fontData =
                            await rootBundle.load('assets/fonts/KulimPark.ttf');
                        Uint8List fontBytes = fontData.buffer.asUint8List();
                        String base64Font = base64.encode(fontBytes);
                        await controller.injectCSSCode(source: '''
 @font-face {
                              font-family: 'KulimPark-Regular';
                              src: url(data:font/ttf;base64,$base64Font) format('truetype');
                            }
                            
                                                                      .card {
                                                                      font-family: "KulimPark-Regular"; 
                                                                      font-size: 14px;
                                                                      }

                                                                       .app-main {
                                              align-content: center;
                                              }
                                              br {
    display: none;
}
                                                   
                                            
                                              
                                             


''');
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
                      onLoadHttpError:
                          (controller, url, statusCode, description) {
                        getcontroller.handleloadingpage(isloadingpage: false);
                        getcontroller.handlenetworkpage(iserrorpage: true);
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          print('Loading complete');
                        }
                      },
                      initialSettings: InAppWebViewSettings(supportZoom: false),
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
