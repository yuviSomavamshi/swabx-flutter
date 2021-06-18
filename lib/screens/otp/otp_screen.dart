import 'package:swabx/screens/sign_in/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:swabx/size_config.dart';

import 'components/body.dart';

// ignore: must_be_immutable
class OtpScreen extends StatelessWidget {
  static String routeName = "/otp";
  String email;
  String nextScreen = SignInScreen.routeName;
  OtpScreen({Key key, @required this.email, this.nextScreen}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: Text("OTP Verification"),
      ),
      body: Body(email: email, nextScreen: nextScreen),
    );
  }
}
