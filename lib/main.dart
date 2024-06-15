import 'package:flutter/material.dart';
import 'package:geotagcameraapp/pages/camerapage.dart';
import 'package:geotagcameraapp/router/router.dart';

void main() {
  runApp(const MyApp());
}

final _appRouter = AppRouter();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.config(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'KulimPark',
        useMaterial3: false,
      ),
    );
  }
}
