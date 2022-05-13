// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:work/routes/routes_names.dart';
// void main() {
//   runApp(const MaterialApp(
//     home: MyApp(),
//   ));
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       color: Colors.indigo,
//       title: "Demo App",
//       initialRoute: RoutesNames.splash,
//       getPages: RoutesNames().pages,
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:async';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: readMeater(),
    ),
  );
}

class readMeater extends StatefulWidget {
  const readMeater({Key? key}) : super(key: key);

  @override
  _readMeaterState createState() => _readMeaterState();
}

class _readMeaterState extends State<readMeater> {
  String imagePath = "asd";
  File? myImagePath;
  String finalText = ' ';
  bool isLoaded = false;
  XFile? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              color: Colors.teal,
              child: isLoaded
                  ? Image.file(
                      myImagePath!,
                      fit: BoxFit.fill,
                    )
                  : const Text("This is image section "),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  getImage();
                },
                child: const Icon(
                  Icons.camera,
                  size: 25,
                  color: Colors.black,
                ),
              ),
            ),
            Text(
              finalText != null ? finalText : "This is my text",
            ),
          ],
        ),
      ),
    );
  }

  Future getText(String path) async {
    finalText = "";
    final inputImage = InputImage.fromFilePath(path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText _reconizedText =
        await textDetector.processImage(inputImage);

    for (TextBlock block in _reconizedText.blocks) {
      for (TextLine textLine in block.lines) {
        for (TextElement textElement in textLine.elements) {
          finalText = finalText + " " + textElement.text;
        }
        finalText = finalText + '\n';
      }
    }
    setState(() {});
  }

  Future<void> _cropImage() async {
    if (myImagePath != null) {
      File croppedFile = (await ImageCropper().cropImage(
        sourcePath: myImagePath!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        androidUiSettings: const AndroidUiSettings(
          toolbarTitle: 'Cropper',
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: false,
        ),
      )) as File;
      if (croppedFile != null) {
        setState(() {
          myImagePath = croppedFile;
          getText(myImagePath!.path);
        });
      }
    }
  }

  void getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
    );
    myImagePath = File(image!.path);
    isLoaded = true;
    imagePath = image.path.toString();
    await _cropImage();
    setState(() {});
  }
}
