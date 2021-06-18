import 'package:swabx/helper/APIService.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/screens/sign_in/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/size_config.dart';
import 'package:toast/toast.dart';

import 'otp_form.dart';

// ignore: must_be_immutable
class Body extends StatelessWidget {
  String email;
  String nextScreen = SignInScreen.routeName;

  Body({Key key, @required this.email, this.nextScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: SizeConfig.screenHeight * 0.05),
              Text(
                "OTP Verification",
                style: headingStyle,
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.1),
              Wrap(
                children: [
                  Text(
                    "Please enter the 4 digit verification code sent to",
                    style: TextStyle(fontSize: getProportionateScreenWidth(14)),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                        fontSize: getProportionateScreenWidth(16),
                        color: kPrimaryColor),
                  ),
                ],
              ),
              OtpForm(
                nextScreen: nextScreen,
                email: email,
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.1),
              GestureDetector(
                onTap: () async {
                  APIService apiService = new APIService();
                  apiService.forgotPassword(email: email).then((value) async {
                    // if all are valid then go to success screen
                    if (value != null &&
                        value.message != null &&
                        value.message.isNotEmpty) {
                      Toast.show(value.message, context,
                          duration: kToastDuration, gravity: Toast.BOTTOM);
                      if (value.statusCode == 200) {
                        SharedPreferencesHelper.setEmail(email);
                      }
                    }
                  });
                },
                child: Text(
                  "Resend OTP Code",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Row buildTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("This code will expired in "),
        TweenAnimationBuilder(
          tween: Tween(begin: 30.0, end: 0.0),
          duration: Duration(seconds: 30),
          builder: (_, value, child) => Text(
            "00:${value.toInt()}",
            style: TextStyle(color: kPrimaryColor),
          ),
        ),
      ],
    );
  }
}
