import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:geotagcameraapp/controller/tapcontroller.dart';
import 'package:geotagcameraapp/widget/imageviewfull.dart';
import 'package:get/get.dart';

class CameraCapturePage extends StatelessWidget {
  const CameraCapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    GetxTapController controller = Get.put(GetxTapController());
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 249, 234),
      body: GetBuilder<GetxTapController>(builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Take a picture',
                      style: TextStyle(fontSize: 22),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.resetcapture();
                      },
                      child: const Icon(
                        Icons.restore,
                        size: 25,
                      ),
                    )
                  ],
                ),
                for (int i = 0; i < 3; i++)
                  GestureDetector(
                    onTap: controller.capturedimages[i] != null
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImageScreen(
                                      image: controller.capturedimages[i]!),
                                ));
                          }
                        : () => controller.pickImage(i),
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
                          child: controller.capturedimages[i] == null
                              ? controller.isimagecapturedbycam[i]
                                  ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: SizedBox(
                                              width: 50,
                                              height: 50,
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                  child: Image.file(
                                      controller.capturedimages[i]!,
                                      fit: BoxFit.cover)),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: controller.capturedimages.contains(null)
                      ? null
                      : () {
                          controller.saveImagesToGallery().whenComplete(() {
                            return ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                        'Images Downloaded Successfully')));
                          });
                        },
                  child: const Text('Save to Gallery'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
