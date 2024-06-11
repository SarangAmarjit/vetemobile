import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

  // Future<ByteData> loadAssetFont() async {
  //   ByteData imageData = await rootBundle.load('assets/fonts/fonts3.zip');

  //   setState(() {});
  //   return imageData;
  // }

  Future<String> _getAndEmbedLocation(String imagePath) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
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

    // _getAddressFromLatLng(Position position) async {
    //   try {
    //     List<Placemark> placemarks = await placemarkFromCoordinates(
    //         position.latitude, position.longitude);

    //     Placemark place = placemarks[0];

    //     setState(() {
    //       _currentAddress =
    //           "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
    //     });
    //   } catch (e) {
    //     print(e);
    //   }
    // }
    // Get current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final gpsCoordinates =
        'Lat: ${position.latitude}, Lon: ${position.longitude}';
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks[0];
    img.Image originalImage =
        img.decodeImage(File(imagePath).readAsBytesSync())!;
    img.drawString(originalImage, gpsCoordinates,
        maskChannel: img.Channel.luminance,
        x: originalImage.width ~/ 1.5,
        y: originalImage.height - 200,
        font: img.arial48);

    final directory = await getApplicationDocumentsDirectory();
    final newPath = '${directory.path}/image_with_location.png';
    File(newPath).writeAsBytesSync(
      img.encodeJpg(
        originalImage,
        quality: 50,
      ),
    );
    return newPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final pickedFile =
                await _picker.pickImage(source: ImageSource.camera);

            if (pickedFile != null) {
              final newPath = await _getAndEmbedLocation(pickedFile.path);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DisplayPictureScreen(imagePath: newPath),
                ),
              );
            }
          },
          child: const Text('Take Picture'),
        ),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}
