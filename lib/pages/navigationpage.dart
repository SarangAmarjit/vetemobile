import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geotagcameraapp/controller/tapcontroller.dart';
import 'package:geotagcameraapp/pages/camerapage.dart';
import 'package:get/get.dart';

@RoutePage()
class NavBarPage extends StatelessWidget {
  const NavBarPage({super.key});

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Home Page',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    CameraCapturePage(),
    Text(
      'Log Out Page',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    GetxTapController controller = Get.put(GetxTapController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vety App'),
      ),
      body: GetBuilder<GetxTapController>(builder: (_) {
        return Center(
          child: _widgetOptions.elementAt(controller.selectedIndex),
        );
      }),
      bottomNavigationBar: GetBuilder<GetxTapController>(builder: (_) {
        return BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_rounded),
              label: 'Capture',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Log Out',
            ),
          ],
          currentIndex: controller.selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: (value) {
            controller.onItemTapped(value);
          },
        );
      }),
    );
  }
}
