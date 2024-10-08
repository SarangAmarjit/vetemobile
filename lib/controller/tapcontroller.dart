import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class GetxTapController extends GetxController {
  // final BuildContext context;

  // GetxTapController({required this.context});
  //table
  InAppWebViewController? webViewController;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _capturedimages = [
    {"image": null, "location": ''},
    {"image": null, "location": ''},
    {"image": null, "location": ''}
  ];
  List<Map<String, dynamic>> get capturedimages => _capturedimages;

  final List<bool> _isimagecapturedbycam = [false, false, false];
  List<bool> get isimagecapturedbycam => _isimagecapturedbycam;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  bool _isErrorPageDisplayed = false;
  bool get isErrorPageDisplayed => _isErrorPageDisplayed;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _iscomingfromnavbar = false;
  bool get iscomingfromnavbar => _iscomingfromnavbar;

  String _username = '';
  String get username => _username;
  @override
  Future<void> onInit() async {
    super.onInit();
    Future.delayed(const Duration(seconds: 2))
        .whenComplete(() => FlutterNativeSplash.remove());
    log('finish splash');
  }

  void setusername({required String name}) {
    _username = name;
    update();
  }

  void handleloadingpage({required bool isloadingpage}) {
    log(isloadingpage.toString());
    _isLoading = isloadingpage;

    update();
  }

  void handleinitialpage({required bool iscomingnavbar}) {
    _iscomingfromnavbar = iscomingnavbar;
    update();
  }

  void handlenetworkpage({required bool iserrorpage}) {
    log('ErrorPage :$iserrorpage');
    if (iserrorpage) {
      _isErrorPageDisplayed = iserrorpage;
      update();
    } else {
      _isLoading = true;
      _isErrorPageDisplayed = iserrorpage;
      update();
    }
  }

  Future<void> pickImage(int index) async {
    final pickedFile = await _picker.pickImage(
        imageQuality: 30,
        source: ImageSource.camera,
        maxHeight: 2304,
        maxWidth: 1300);

    if (pickedFile != null) {
      _isimagecapturedbycam[index] = true;
      update();

      await _getAndEmbedLocation(imagePath: pickedFile.path, index: index)
          .then((newPath) {
        _isimagecapturedbycam[index] = false;
        _capturedimages[index]['image'] = File(newPath);
        update();
      });
    }
  }

  Future<String> _getAndEmbedLocation(
      {required String imagePath, required int index}) async {
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
        forceAndroidLocationManager: true,
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    final address =
        await getAddressFromLatLng(position.latitude, position.longitude);
    final gpsCoordinates =
        'Lat: ${(position.latitude.toStringAsFixed(4))}, Lon: ${(position.longitude.toStringAsFixed(4))}';

    _capturedimages[index]['location'] = gpsCoordinates;
    update();

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
        yposition: 100,
        vetewidth: address.length < 10 ? vetex : null,
        font: font);
    drawStringAtRightCorner(
        originalImage: originalImage,
        address: gpsCoordinates,
        yposition: 180,
        font: font,
        vetewidth: null);
    drawStringAtRightCorner(
        originalImage: originalImage,
        address: _username,
        yposition: 260,
        font: font,
        vetewidth: vetex);
    drawStringAtRightCorner(
        originalImage: originalImage,
        address: 'MVU 1962',
        yposition: 340,
        font: font,
        vetewidth: vetex);

    final directory = await getApplicationDocumentsDirectory();
    final newPath =
        '${directory.path}/image_with_location_${DateTime.now().millisecondsSinceEpoch}.jpg';
    File(newPath).writeAsBytesSync(
      img.encodeJpg(
        originalImage,
      ),
    );

    var exif = await Exif.fromPath(newPath);
    // Convert coordinates to DMS format
    // Convert coordinates to DMS format

    // Determine latitude and longitude reference
    String latitudeRef = position.latitude >= 0 ? 'N' : 'S';
    String longitudeRef = position.longitude >= 0 ? 'E' : 'W';

    // Read existing EXIF data

    // Write EXIF data
    // Write EXIF data
    await exif.writeAttributes({
      'GPSLatitude': position.latitude,
      'GPSLatitudeRef': latitudeRef,
      'GPSLongitude': position.longitude,
      'GPSLongitudeRef': longitudeRef,
    });
    // Save changes to the image file

    var imagedata1 = await exif.getAttributes();
    log('After DECODE IMAGE :$imagedata1');

    await exif.close(); // Ensure changes are saved
    // Add GPS data

    return newPath;
  }

  List<int> convertToDMS(double coordinate) {
    coordinate = coordinate.abs();
    int degrees = coordinate.floor();
    double minutesFloat = (coordinate - degrees) * 60;
    int minutes = minutesFloat.floor();
    double seconds = (minutesFloat - minutes) *
        60 *
        10000; // scale seconds to avoid floating point
    return [degrees, minutes, seconds.round()];
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        log('Full Address : $place');
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

  void grandpermission() async {
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
  }

  Future saveImagesToGallery() async {
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
      for (var items in _capturedimages) {
        if (items['image'] != null) {
          File imagefile = items['image'];

          final result = await ImageGallerySaver.saveFile(imagefile.path);

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
                  url: WebUri('https://vetymanipur.in/MV/mv_task.aspx')));
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
            onPressed: () {
              _isLoading = true;
              update();
              context.router.replaceNamed('/logout');
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void resetcapture() {
    _capturedimages = [
      {"image": null, "location": ''},
      {"image": null, "location": ''},
      {"image": null, "location": ''}
    ];
    update();
  }
}
