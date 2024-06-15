import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:auto_route/auto_route.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;

import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';

class GetxTapController extends GetxController {
  // final BuildContext context;

  // GetxTapController({required this.context});
  //table
  InAppWebViewController? webViewController;
  final ImagePicker _picker = ImagePicker();
  List<File?> _capturedimages = [null, null, null];
  List<File?> get capturedimages => _capturedimages;

  final List<bool> _isimagecapturedbycam = [false, false, false];
  List<bool> get isimagecapturedbycam => _isimagecapturedbycam;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  Future<void> pickImage(int index) async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 30,
        maxHeight: 2304,
        maxWidth: 1300);

    if (pickedFile != null) {
      _isimagecapturedbycam[index] = true;
      update();

      await _getAndEmbedLocation(pickedFile.path).then((newPath) {
        _isimagecapturedbycam[index] = false;
        _capturedimages[index] = File(newPath);
        update();
      });
    }
  }

  Future<String> _getAndEmbedLocation(String imagePath) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final address =
        await getAddressFromLatLng(position.latitude, position.longitude);
    final gpsCoordinates =
        'Lat: ${position.latitude}, Lon: ${position.longitude}';
    // final fontData = await rootBundle.load('assets/fonts/kulimpark3.zip');
    // final font = img.BitmapFont.fromZip(fontData.buffer.asUint8List());
    final font = img.arial48;

    var vetewidth = getTextWidth(gpsCoordinates, font);

    img.Image originalImage =
        img.decodeImage(File(imagePath).readAsBytesSync())!;
    int vetex = originalImage.width - vetewidth;
    drawStringAtRightCorner(
        originalImage: originalImage,
        address: address,
        yposition: 20,
        vetewidth: null,
        font: font);
    drawStringAtRightCorner(
        originalImage: originalImage,
        address: gpsCoordinates,
        yposition: 100,
        font: font,
        vetewidth: null);
    drawStringAtRightCorner(
        originalImage: originalImage,
        address: 'Vety 1962',
        yposition: 180,
        font: font,
        vetewidth: vetex);

    final directory = await getApplicationDocumentsDirectory();
    final newPath =
        '${directory.path}/image_with_location_${DateTime.now().millisecondsSinceEpoch}.jpg';
    File(newPath).writeAsBytesSync(
      img.encodeJpg(originalImage, quality: 20, chroma: img.JpegChroma.yuv420),
    );
    return newPath;
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        log(place.postalCode.toString());
        String address = "${place.locality}";
        return address;
      } else {
        return "No address found";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  int getTextWidth(String text, img.BitmapFont font) {
    log("Address : $text");
    log(text.length.toString());
    int width = 0;
    for (int i = 0; i < text.length; i++) {
      var ch = text.codeUnitAt(i);
      var glyph = font.characters[ch];
      glyph ??= font.characters[48];
      width += glyph!.width;
    }
    return width;
  }

  void drawStringAtRightCorner(
      {required img.Image originalImage,
      required String address,
      required int yposition,
      required int? vetewidth,
      required img.BitmapFont font}) async {
    var textWidth = getTextWidth(address, font);

    int x = originalImage.width - textWidth - textWidth ~/ 2;

    int y = originalImage.height - font.lineHeight - yposition;

    img.drawString(
      originalImage,
      address,
      x: vetewidth ?? x,
      y: y,
      font: font,
    );
  }

  Future<void> saveImagesToGallery() async {
    // Request storage permissions if not already granted
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      final plugin = DeviceInfoPlugin();
      final android = await plugin.androidInfo;
      log('Android SDK Version :${android.version.sdkInt}');
      status = android.version.sdkInt < 30
          ? await Permission.storage.request()
          : await Permission.manageExternalStorage.request();
    }

    if (status.isGranted) {
      for (var image in _capturedimages) {
        if (image != null) {
          final Uint8List bytes = await image.readAsBytes();
          final result = await ImageGallerySaver.saveImage(bytes);

          log('Image saved to gallery: $result');
        }
      }
    } else {
      log('Storage permission not granted');
    }
  }

  // Navigation Bar Index Change

  void onItemTapped(int index, BuildContext context) {
    if (index == 3) {
      // If the log out button is pressed
      showLogoutDialog(context);
    } else {
      if (index == 0) {
        if (_selectedIndex == index) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(
                  url: WebUri('http://vety.cubeten.com/MV/mv_task.aspx')));
        }
      }

      log(index.toString());
      _selectedIndex = index;
      update();
    }

    update();
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          ElevatedButton(
            onPressed: () => context.router.pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => context.router.replaceNamed('/logout'),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void resetcapture() {
    _capturedimages = [null, null, null];
    update();
  }
}
