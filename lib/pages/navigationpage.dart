import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geotagcameraapp/controller/tapcontroller.dart';
import 'package:geotagcameraapp/pages/camerapage.dart';
import 'package:geotagcameraapp/pages/livetracking.dart';
import 'package:geotagcameraapp/pages/logoutpage.dart';

import 'package:geotagcameraapp/pages/loginpage.dart';
import 'package:geotagcameraapp/pages/mytaskpage.dart';
import 'package:geotagcameraapp/pages/networkerrorpage.dart';
import 'package:get/get.dart';

@RoutePage()
class NavBarPage extends StatelessWidget {
  const NavBarPage({super.key});

  static final List<Widget> _widgetOptions = <Widget>[
    const MytaskPage(),
    LiveTrackingPage(),
    const CameraCapturePage(),
    LogoutPage()
  ];

  @override
  Widget build(BuildContext context) {
    GetxTapController controller = Get.put(GetxTapController());
    return GetBuilder<GetxTapController>(builder: (_) {
      return controller.isErrorPageDisplayed
          ? const NetworkErrorPage()
          : Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Image.asset(
                    'assets/images/Kanglasha.png',
                  ),
                ),
                title: const Text(
                  '1962 - Manipur Mobile Veterinary',
                  style: TextStyle(color: Colors.black),
                ),
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
                      label: 'Task List',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.spatial_tracking),
                      label: 'Live Tracking',
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
                  selectedItemColor: const Color.fromARGB(255, 62, 175, 66),
                  unselectedItemColor: const Color.fromARGB(255, 97, 96, 96),
                  showUnselectedLabels: true,
                  onTap: (value) {
                    controller.onItemTapped(value, context);
                  },
                );
              }),
            );
    });
  }
}
