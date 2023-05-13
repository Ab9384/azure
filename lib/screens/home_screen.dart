import 'dart:io';

import 'package:azure/api/request_helper.dart';
import 'package:azure/global.dart';
import 'package:azure/screens/output.dart';
import 'package:azure/widgets/progress_dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import '../brand_colors.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController controller;
  late XFile? image;
  String? imageUrl;
  File? imageFile;
  final ImagePicker picker = ImagePicker();
  bool isFlashOn = false;
  int _selectedIndex = 0;
  List<String> options = const [
    'Analyze Image',
    'Describe Image',
    'Detect Objects',
    'OCR',
    'Tag Image'
  ];
  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // on single back press initialize camera again and set imageFile to null
      onWillPop: () async {
        setState(() {
          imageFile = null;
          imageUrl = null;
        });
        if (imageUrl != null) {
          await RequestHelper.deleteImageFromFirebaseStorage(imageUrl!);
        }
        controller = CameraController(cameras[0], ResolutionPreset.max);
        controller.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        }).catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                // Handle access errors here.
                break;
              default:
                // Handle other errors here.
                break;
            }
          }
        });
        return false;
      },

      child: Scaffold(
        backgroundColor: BrandColors.backgroundColor,
        body: Column(
          children: [
            Stack(children: [
              // camera preview
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 60,
                  child: imageFile == null
                      ? (controller.value.isInitialized
                          ? CameraPreview(controller)
                          : const Center(
                              child: CircularProgressIndicator(),
                            ))
                      : Image.file(imageFile!),
                ),
              ),
              // click picture button and gallery button center bottom
              Positioned(
                bottom: 20,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // gallery button
                      GestureDetector(
                        onTap: () async {
                          // Pick an image.
                          image = await picker.pickImage(
                              source: ImageSource.gallery);
                          setState(() {
                            if (image != null) {
                              imageFile = File(image!.path);
                              print('image size: ${imageFile!.lengthSync()}');
                              // if image size is greater than 4MB
                              if (imageFile!.lengthSync() > 4000000) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text(
                                        'Image size should be less than 4MB'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                                imageFile = null;
                              }
                            } else {
                              print('No image selected.');
                            }
                          });
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      // click picture button
                      Container(
                        height: 90,
                        width: 90,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                              color: Colors.white,
                              onPressed: () async {
                                if (imageUrl == null) {
                                  if (imageFile == null) {
                                    print('Image not selected');
                                    // camera click
                                    if (!controller.value.isInitialized) {
                                      print('Error: select a camera first.');
                                    } else if (controller
                                        .value.isTakingPicture) {
                                      print('A capture is already pending, ');
                                    } else {
                                      image = await controller.takePicture();
                                      setState(() {
                                        imageFile = File(image!.path);
                                      });
                                      print(
                                          'image size: ${imageFile!.lengthSync()}');
                                      // if image size is greater than 4MB
                                      if (imageFile!.lengthSync() > 4000000) {
                                        // ignore: use_build_context_synchronously
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text('Error'),
                                            content: const Text(
                                                'Image size should be less than 4MB'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                        imageFile = null;
                                      } else {
                                        // ignore: use_build_context_synchronously
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const ProgressDialog(
                                                  status: 'Uploading Image',
                                                ));
                                        imageUrl = await RequestHelper
                                            .uploadImageToFirebaseStorage(
                                                imageFile!, image!.name);

                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                        // ignore: use_build_context_synchronously
                                        await decidingFunction(imageUrl!);
                                        // ignore: use_build_context_synchronously
                                        RequestHelper.navigateTo(
                                            context,
                                            Output(
                                                responsee: decodeJson,
                                                heading: getHeadingBasedOnIndex(
                                                    _selectedIndex),
                                                imageUrl: imageUrl!),
                                            1);
                                      }
                                    }
                                  } else {
                                    print('Image selected');
                                    showDialog(
                                        context: context,
                                        builder: (context) =>
                                            const ProgressDialog(
                                              status: 'Uploading Image',
                                            ));
                                    imageUrl = await RequestHelper
                                        .uploadImageToFirebaseStorage(
                                            imageFile!, image!.name);

                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(context);
                                  }
                                }
                                print('image url: $imageUrl');
                                // ignore: use_build_context_synchronously
                                await decidingFunction(imageUrl!);
                                // ignore: use_build_context_synchronously
                                RequestHelper.navigateTo(
                                    context,
                                    Output(
                                        responsee: decodeJson,
                                        heading: getHeadingBasedOnIndex(
                                            _selectedIndex),
                                        imageUrl: imageUrl!),
                                    1);
                              },
                              icon: const Icon(
                                Icons.search,
                                color: Colors.black,
                                size: 30,
                              )),
                        ),
                      ),

                      // change camera
                      GestureDetector(
                        onTap: () {
                          //  switch camera direction
                          controller.description == cameras[0]
                              ? controller = CameraController(
                                  cameras[1], ResolutionPreset.max)
                              : controller = CameraController(
                                  cameras[0], ResolutionPreset.max);
                          controller.initialize().then((_) {
                            if (!mounted) {
                              return;
                            }
                            setState(() {});
                          }).catchError((Object e) {
                            if (e is CameraException) {
                              switch (e.code) {
                                case 'CameraAccessDenied':
                                  // Handle access errors here.
                                  break;
                                default:
                                  // Handle other errors here.
                                  break;
                              }
                            }
                          });
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_front_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // top appbar with name in center and flash button left
              Positioned(
                top: MediaQuery.of(context).padding.top,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // flash button
                      GestureDetector(
                        onTap: () {
                          print(controller.value.flashMode);
                          setState(() {
                            controller.value.flashMode == FlashMode.off
                                ? controller.setFlashMode(FlashMode.torch)
                                : controller.setFlashMode(FlashMode.off);
                            isFlashOn = !isFlashOn;
                          });
                        },
                        child: Icon(
                          !isFlashOn ? Icons.flash_off : Icons.flash_on,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      // app name
                      Column(
                        children: [
                          const Text(
                            'Azure',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            options[_selectedIndex],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // empty container
                      const Icon(
                        Icons.flash_off,
                        color: Colors.transparent,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.center,
                      child: Text(
                        options[index],
                        style: TextStyle(
                          color: _selectedIndex == index
                              ? Colors.white
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: _selectedIndex == index ? 16.0 : 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<StreamedResponse> decidingFunction(String imageUrl) async {
    StreamedResponse response;
    switch (_selectedIndex) {
      case 0:
        response = await RequestHelper.analyzeImage(imageUrl);

        break;
      case 1:
        response = await RequestHelper.describeImage(imageUrl);
        break;
      case 2:
        response = await RequestHelper.detectObject(imageUrl);
        break;
      case 3:
        response = await RequestHelper.ocrImage(imageUrl);
        break;
      case 4:
        response = await RequestHelper.tagImage(imageUrl);
        break;
      default:
        response = await RequestHelper.analyzeImage(imageUrl);

        break;
    }
    return response;
  }

  String getHeadingBasedOnIndex(int index) {
    switch (index) {
      case 0:
        return 'Analyzed Image';
      case 1:
        return 'Described Image';
      case 2:
        return 'Detected Objects';
      case 3:
        return 'OCR';
      case 4:
        return 'Tagged Image';
      default:
        return 'Analyzed Image';
    }
  }
}
