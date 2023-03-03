import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_choice_chip/flutter_3d_choice_chip.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../misc/global.dart';

class PickerPage extends StatefulWidget {
  const PickerPage({Key? key}) : super(key: key);

  @override
  State<PickerPage> createState() => PickerPageState();
}

class PickerPageState extends State<PickerPage> {
  PostType _mediaType = PostType.image;

  String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Image & Video Picker example"),
      ),
      body: Center(
          child: SingleChildScrollView(
            child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip3D(
                          style: ChoiceChip3DStyle.blue,
                          selected: _mediaType == PostType.image,
                          onSelected: () {
                            setState(() {
                              _mediaType = PostType.image;
                            });
                          },
                          onUnSelected: () {},
                          height: 50,
                          child: const Text(
                            "Image",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        ChoiceChip3D(
                          style: ChoiceChip3DStyle.red,
                          selected: _mediaType == PostType.video,
                          onSelected: () {
                            setState(() {
                              _mediaType = PostType.video;
                            });
                          },
                          onUnSelected: () {},
                          height: 50,
                          child: const Text(
                            "Video",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    (imagePath != null)
                        ? Image.file(File(imagePath!))
                        : Container(
                      width: 300,
                      height: 300,
                      color: Colors.grey[300]!,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.grey,
                                shadowColor: Colors.grey[400],
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                              ),
                              onPressed: () {
                                pickMedia(ImageSource.gallery);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.image,
                                      size: 30,
                                      color: Colors.red,
                                    ),
                                    Text(
                                      "Gallery",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            )),
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.grey,
                                shadowColor: Colors.grey[400],
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                              ),
                              onPressed: () {
                                pickMedia(ImageSource.camera);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 30,
                                      color: Colors.red,
                                    ),
                                    Text(
                                      "Camera",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ],
                )),
          )),
    );
  }

  void pickMedia(ImageSource source) async {
    XFile? file;
    if (_mediaType == PostType.image) {
      file = await ImagePicker().pickImage(source: source);
    } else {
      file = await ImagePicker().pickVideo(source: source);
    }
    if (file != null) {
      imagePath = file.path;
      if (_mediaType == PostType.video) {
        imagePath = await VideoThumbnail.thumbnailFile(
            video: file.path,
            imageFormat: ImageFormat.PNG,
            quality: 100,
            maxWidth: 300,
            maxHeight: 300);
      }
      setState(() {});
    }
  }
}
