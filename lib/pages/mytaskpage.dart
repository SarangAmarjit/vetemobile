import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geotagcameraapp/controller/tapcontroller.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
                  onDownloadStartRequest: (controller, request) async {
                    log("Request all : $request");

                    // Request storage permissions
                    var status = await Permission.storage.status;
                    if (!status.isGranted) {
                      final plugin = DeviceInfoPlugin();
                      final android = await plugin.androidInfo;
                      status = android.version.sdkInt < 30
                          ? await Permission.storage.request()
                          : await Permission.manageExternalStorage.request();
                    }

                    if (status.isGranted) {
                      // Extract the filename from Content-Disposition
                      String contentDisposition =
                          request.contentDisposition ?? '';
                      RegExp regExp = RegExp(r'filename="?([^";]+)"?');
                      final match = regExp.firstMatch(contentDisposition);
                      String extractedFileName = match != null
                          ? match.group(1)!
                          : 'default_filename.xls'; // Fallback filename

                      // Define the download path
                      String downloadsPath = "/storage/emulated/0/Download";
                      String savePath =
                          "$downloadsPath/${request.suggestedFilename}";

                      // Ensure the directory exists
                      final downloadFolder = Directory(downloadsPath);
                      if (!await downloadFolder.exists()) {
                        await downloadFolder.create(recursive: true);
                      }

                      try {
                        // You can use HttpClient to download the file here
                        HttpClient httpClient = HttpClient();
                        var request2 = await httpClient.getUrl(request.url);
                        var response = await request2.close();
                        var file = File(savePath);
                        var bytes =
                            await consolidateHttpClientResponseBytes(response);
                        await file.writeAsBytes(bytes);

                        print("File downloaded to: $savePath");
                        // // Start downloading the file
                        // await FlutterDownloader.enqueue(
                        //   url: request.url
                        //       .toString(), // Ensure this is the correct file URL
                        //   savedDir: downloadsPath,
                        //   fileName: extractedFileName,
                        //   showNotification: true,
                        //   openFileFromNotification: true,
                        // );
                        // log("Download started for: $extractedFileName");
                      } catch (e) {
                        log("Download failed: $e");
                      }
                    } else {
                      log('Storage permission not granted');
                    }
                  },
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
                    log(url);
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
