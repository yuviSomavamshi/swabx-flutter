import 'dart:io';

import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/screens/profile/components/image_picker_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swabx/constants.dart';

class ProfilePic extends StatefulWidget {
  const ProfilePic({
    Key key,
  }) : super(key: key);

  @override
  _ProfilePicState createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic>
    with TickerProviderStateMixin, ImagePickerListener {
  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = new ImagePickerHandler(this, _controller);
    imagePicker.init();
    initImage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: loadImage(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loading();
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else
              return SizedBox(
                height: 115,
                width: 115,
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    CircleAvatar(
                        backgroundColor: kSecondaryColor,
                        radius: (52),
                        child: new Container(
                          height: 180.0,
                          width: 180.0,
                          decoration: new BoxDecoration(
                            image: new DecorationImage(
                              image: _image == null
                                  ? AssetImage(
                                      "assets/images/Profile Image.png")
                                  : new FileImage(_image),
                              fit: BoxFit.scaleDown,
                            ),
                            borderRadius: new BorderRadius.all(
                                const Radius.circular(80.0)),
                          ),
                        )),
                    Positioned(
                      right: -16,
                      bottom: 0,
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        // ignore: deprecated_member_use
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(50)),
                          color: kPrimaryColor,
                          onPressed: () => imagePicker.showDialog(context),
                          child: SvgPicture.asset(
                              "assets/icons/Camera Icon.svg",
                              color: Colors.white,
                              fit: BoxFit.fitWidth),
                        ),
                      ),
                    )
                  ],
                ),
              );
          }
        });
  }

  @override
  userImage(File _image) {
    setState(() {
      setImagePath(_image);
      this._image = _image;
    });
  }

  void initImage() async {
    String path = await SharedPreferencesHelper.getString("imagePath");
    if (path != null) {
      _image = File(path);
    }
  }

  void setImagePath(File image) async {
    await SharedPreferencesHelper.setString("imagePath", image.path);
  }

  Future<String> loadImage() async {
    String path = await SharedPreferencesHelper.getString("imagePath");
    if (path != null) {
      _image = File(path);
    }
    return Future.value(path); // return your response
  }
}
