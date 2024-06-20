import 'package:flutter/material.dart';
import 'package:geotagcameraapp/controller/tapcontroller.dart';
import 'package:geotagcameraapp/widget/imageviewfull.dart';
import 'package:get/get.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInstructions();
    });
  }

  void showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'How to Use',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '1. Accept Permissions:',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                Text(
                    '   - Ensure that you accept the storage and GPS permissions when prompted.'),
                SizedBox(height: 15),
                Text(
                  '2. Capture Images:',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                Text(
                    '   - You can capture one or more images as per your requirement.'),
                Text(
                    '   - After captured, tap on it to view it in full screen.'),
                SizedBox(height: 15),
                Text(
                  '3. Save Images to Gallery:',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                Text(
                    '   - Once you have captured at least one image, tap on the "Save to Gallery" button.'),
                SizedBox(height: 15),
                Text(
                  '4. Upload Images:',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                Text(
                    '   - After saving, you should upload these images when submitting your report in the "Submit Report" section.'),
                SizedBox(height: 10),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    GetxTapController controller = Get.put(GetxTapController());
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 249, 234),
      body: GetBuilder<GetxTapController>(builder: (_) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Take Pictures of injured animal :',
                          style: TextStyle(fontSize: 22),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                controller.resetcapture();
                              },
                              child: const Icon(
                                Icons.restore,
                                size: 25,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                                          const Icon(Icons.camera_alt,
                                              size: 50),
                                          Text(
                                            'Capture Image ${(i + 1).toString()}',
                                            style:
                                                const TextStyle(fontSize: 17),
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
                    onPressed: controller.capturedimages
                            .any((file) => file != null)
                        ? () {
                            controller.saveImagesToGallery().whenComplete(() {
                              return ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text(
                                          'Images Downloaded Successfully')));
                            });
                          }
                        : null,
                    child: const Text('Save to Gallery'),
                  ),
                  const SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
