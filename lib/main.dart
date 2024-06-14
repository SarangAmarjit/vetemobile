import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TakePictureScreen(),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File?> _images = [null, null, null];

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final newPath = await _getAndEmbedLocation(pickedFile.path);
      setState(() {
        _images[index] = File(newPath);
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
    var vetewidth = getTextWidth(gpsCoordinates, img.arial48);

    img.Image originalImage =
        img.decodeImage(File(imagePath).readAsBytesSync())!;
    int vetex = originalImage.width - vetewidth;
    drawStringAtRightCorner(
        originalImage: originalImage,
        address: address,
        yposition: 20,
        vetewidth: null);
    drawStringAtRightCorner(
        originalImage: originalImage,
        address: gpsCoordinates,
        yposition: 100,
        vetewidth: null);
    drawStringAtRightCorner(
        originalImage: originalImage,
        address: 'Vety',
        yposition: 180,
        vetewidth: vetex);

    final directory = await getApplicationDocumentsDirectory();
    final newPath =
        '${directory.path}/image_with_location_${DateTime.now().millisecondsSinceEpoch}.png';
    File(newPath).writeAsBytesSync(
      img.encodeJpg(
        originalImage,
        quality: 50,
      ),
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
      required int? vetewidth}) async {
    final fontData = await rootBundle.load('assets/fonts/kulimpark3.zip');
    final font = img.BitmapFont.fromZip(fontData.buffer.asUint8List());

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

  Future<void> _saveImagesToGallery() async {
    // Request storage permissions if not already granted
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }

    if (status.isGranted) {
      for (var image in _images) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: Column(
        children: [
          for (int i = 0; i < 3; i++)
            GestureDetector(
              onTap: () => _pickImage(i),
              child: Container(
                margin: const EdgeInsets.all(8.0),
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.black),
                ),
                child: _images[i] == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : Image.file(_images[i]!, fit: BoxFit.cover),
              ),
            ),
          ElevatedButton(
            onPressed: _saveImagesToGallery,
            child: const Text('Save to Gallery'),
          ),
        ],
      ),
    );
  }
}
