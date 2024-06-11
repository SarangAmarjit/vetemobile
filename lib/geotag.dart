// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:path_provider/path_provider.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData.dark(),
//       home: const TakePictureScreen(),
//     );
//   }
// }

// class TakePictureScreen extends StatefulWidget {
//   const TakePictureScreen({super.key});

//   @override
//   TakePictureScreenState createState() => TakePictureScreenState();
// }

// class TakePictureScreenState extends State<TakePictureScreen> {
//   final ImagePicker _picker = ImagePicker();

//   Future<String> _getAndEmbedLocation(String imagePath) async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }

//     // Check for location permissions
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }

//     // Get current location
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     final gpsCoordinates =
//         'Lat: ${position.latitude}, Lon: ${position.longitude}';

//     List<Placemark> placemarks = await placemarkFromCoordinates(
//       position.latitude,
//       position.longitude,
//     );
//     Placemark place = placemarks[0];
//     final address =
//         "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

//     // Load the image
//     final file = File(imagePath);
//     final bytes = await file.readAsBytes();
//     final codec = await ui.instantiateImageCodec(bytes);
//     final frame = await codec.getNextFrame();
//     final image = frame.image;

//     // Pass the image and text to the CustomPainter widget
//     final directory = await getApplicationDocumentsDirectory();
//     final newPath = '${directory.path}/image_with_location.png';
//     return newPath;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Take a picture')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             final pickedFile =
//                 await _picker.pickImage(source: ImageSource.camera);

//             if (pickedFile != null) {
//               final newPath = await _getAndEmbedLocation(pickedFile.path);

//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       DisplayPictureScreen(imagePath: pickedFile.path),
//                 ),
//               );
//             }
//           },
//           child: const Text('Take Picture'),
//         ),
//       ),
//     );
//   }
// }

// class DisplayPictureScreen extends StatelessWidget {
//   final String imagePath;

//   const DisplayPictureScreen({super.key, required this.imagePath});

//   Future<ui.Image> _loadImage(String path) async {
//     final file = File(path);
//     final bytes = await file.readAsBytes();
//     final codec = await ui.instantiateImageCodec(bytes);
//     final frame = await codec.getNextFrame();
//     return frame.image;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.amber,
//       appBar: AppBar(
//         title: const Text('Display the Picture'),
//         backgroundColor: Colors.blue,
//       ),
//       body: FutureBuilder<ui.Image>(
//         future: _loadImage(imagePath),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             } else {
//               final image = snapshot.data!;
//               const positionText = 'Sample Text'; // Placeholder for actual text
//               return Center(
//                 child: FittedBox(
//                   fit: BoxFit.contain,
//                   child: SizedBox(
//                     width: image.width.toDouble(),
//                     height: image.height.toDouble(),
//                     child: CustomPaint(
//                       painter: ImageWithTextPainter(
//                         image: image,
//                         text: positionText,
//                         textStyle: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 100,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }

// class ImageWithTextPainter extends CustomPainter {
//   final ui.Image image;
//   final String text;
//   final TextStyle textStyle;

//   ImageWithTextPainter({
//     required this.image,
//     required this.text,
//     required this.textStyle,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Draw the image
//     canvas.drawImage(image, Offset.zero, Paint());

//     // Draw the text
//     final textSpan = TextSpan(text: text, style: textStyle);
//     final textPainter = TextPainter(
//       text: textSpan,
//       textDirection: TextDirection.ltr,
//     );
//     textPainter.layout(minWidth: 0, maxWidth: size.width);
//     final offset =
//         Offset(size.width / 1.5, size.height - 100); // Position of the text
//     textPainter.paint(canvas, offset);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
