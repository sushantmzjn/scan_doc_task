import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_scan/constant/image_picker_provider/image_picker_provider.dart';
import 'package:image_scan/view/table_view.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  Future<void> _showImagePickerDialog(
      BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  ref.read(imageProvider.notifier).pickImage(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  ref.read(imageProvider.notifier).pickImage(false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _scanDocument(BuildContext context, WidgetRef ref) async {
    final pickedImage = ref.watch(imageProvider);
    if (pickedImage == null) return;

    final inputImage = InputImage.fromFile(File(pickedImage.path));
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableView(recognizedText: recognizedText),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickedImage = ref.watch(imageProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 450.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  child: pickedImage == null
                      ? const Text('No image selected')
                      : Image.file(File(pickedImage.path),
                          fit: BoxFit.fitHeight),
                ),
                if (pickedImage != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        ref.read(imageProvider.notifier).resetImage();
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _showImagePickerDialog(context, ref);
              },
              child: const Text('Pick Image'),
            ),
            if (pickedImage != null)
              ElevatedButton(
                onPressed: () async {
                  await _scanDocument(context, ref);
                },
                child: const Text('Scan doc'),
              ),
          ],
        ),
      ),
    );
  }
}
