import 'dart:developer';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
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
      theme: ThemeData(
        fontFamily: 'KulimPark',
        useMaterial3: true,
      ),
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
  List<bool> isimageloaded = [false, false, false];
  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 30,
        maxHeight: 2304,
        maxWidth: 1300);

    if (pickedFile != null) {
      setState(() {
        isimageloaded[index] = true;
      });
      final newPath = await _getAndEmbedLocation(pickedFile.path);
      setState(() {
        isimageloaded[index] = false;
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
        address: 'Vety',
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

  Future<void> _saveImagesToGallery() async {
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

  void _viewImageFullScreen(File image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageScreen(image: image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 249, 234),
      appBar: AppBar(title: const Text('Take a picture')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (int i = 0; i < 3; i++)
                GestureDetector(
                  onTap: _images[i] != null
                      ? () => _viewImageFullScreen(_images[i]!)
                      : () => _pickImage(i),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Card(
                      elevation: 10,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(10)),
                        child: _images[i] == null
                            ? isimageloaded[i]
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: CircularProgressIndicator()),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.camera_alt, size: 50),
                                      Text(
                                        'Capture Image ${(i + 1).toString()}',
                                        style: const TextStyle(fontSize: 17),
                                      )
                                    ],
                                  )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child:
                                    Image.file(_images[i]!, fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: _images.contains(null)
                    ? null
                    : () {
                        _saveImagesToGallery().whenComplete(() {
                          return ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  backgroundColor: Colors.green,
                                  content:
                                      Text('Images Downloaded Successfully')));
                        });
                      },
                child: const Text('Save to Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImageScreen extends StatelessWidget {
  final File image;

  const FullScreenImageScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Full Screen Image')),
      body: Center(
        child: Image.file(image),
      ),
    );
  }
}
