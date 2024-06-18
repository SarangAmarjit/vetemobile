import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geotagcameraapp/controller/tapcontroller.dart';
import 'package:get/get.dart';

class NetworkErrorPage extends StatelessWidget {
  const NetworkErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    GetxTapController controller = Get.put(GetxTapController());
    return Scaffold(
      body: GetBuilder<GetxTapController>(builder: (_) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.error, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'No Internet Connection',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  controller.handlenetworkpage(iserrorpage: false);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
