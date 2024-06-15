import 'dart:io';

import 'package:flutter/material.dart';

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
