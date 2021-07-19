import 'dart:async';
import 'dart:io';

import 'package:swabx/screens/profile/components/image_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHandler {
  ImagePickerDialog imagePicker;
  AnimationController _controller;
  ImagePickerListener _listener;

  ImagePickerHandler(this._listener, this._controller);

  openCamera() async {
    imagePicker.dismissDialog();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    cropImage(File(pickedFile.path));
  }

  openGallery() async {
    imagePicker.dismissDialog();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    cropImage(File(pickedFile.path));
  }

  void init() {
    imagePicker = new ImagePickerDialog(this, _controller);
    imagePicker.initState();
  }

  Future cropImage(File image) async {
    File croppedFile = await ImageCropper.cropImage(
      cropStyle: CropStyle.circle,
      sourcePath: image.path,
      maxWidth: 512,
      maxHeight: 512,
    );
    _listener.userImage(croppedFile);
  }

  showDialog(BuildContext context) {
    imagePicker.getImage(context);
  }
}

abstract class ImagePickerListener {
  userImage(File _image);
}
