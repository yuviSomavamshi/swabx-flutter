import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/models/API.dart';
import 'package:flutter/material.dart';
import 'package:swabx/components/default_button.dart';
import 'package:swabx/size_config.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:swabx/screens/sign_in/sign_in_screen.dart';
import 'package:toast/toast.dart';
import 'package:swabx/constants.dart';

// ignore: must_be_immutable
class OtpForm extends StatefulWidget {
  String email;
  String nextScreen = SignInScreen.routeName;
  OtpForm({Key key, @required this.nextScreen, @required this.email})
      : super(key: key);

  @override
  _OtpFormState createState() =>
      _OtpFormState(nextScreen: nextScreen, email: email);
}

class _OtpFormState extends State<OtpForm> {
  String email;
  String nextScreen = SignInScreen.routeName;
  _OtpFormState({@required this.nextScreen, @required this.email});

  FocusNode pin2FocusNode;
  FocusNode pin3FocusNode;
  FocusNode pin4FocusNode;
  int pin1;
  int pin2;
  int pin3;
  int pin4;

  @override
  void initState() {
    super.initState();

    pin2FocusNode = FocusNode();
    pin3FocusNode = FocusNode();
    pin4FocusNode = FocusNode();
    pin1 = 0;
    pin2 = 0;
    pin3 = 0;
    pin4 = 0;
  }

  @override
  void dispose() {
    super.dispose();
    pin2FocusNode.dispose();
    pin3FocusNode.dispose();
    pin4FocusNode.dispose();
  }

  void nextField(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          SizedBox(height: SizeConfig.screenHeight * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: getProportionateScreenWidth(60),
                child: TextFormField(
                  autofocus: true,
                  obscureText: true,
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    if (value.length == 1) {
                      pin1 = int.parse(value);
                    }
                    nextField(value, pin2FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(60),
                child: TextFormField(
                  focusNode: pin2FocusNode,
                  obscureText: true,
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    if (value.length == 1) {
                      pin2 = int.parse(value);
                    }
                    nextField(value, pin3FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(60),
                child: TextFormField(
                  focusNode: pin3FocusNode,
                  obscureText: true,
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    if (value.length == 1) {
                      pin3 = int.parse(value);
                    }
                    nextField(value, pin4FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(60),
                child: TextFormField(
                  focusNode: pin4FocusNode,
                  obscureText: true,
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    if (value.length == 1) {
                      pin4 = int.parse(value);
                      pin4FocusNode.unfocus();
                      // Then you need to check is the code is correct or not
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.05),
          DefaultButton(
            text: "Continue",
            press: () async {
              APIService apiService = new APIService();
              final String token = pin1.toString() +
                  pin2.toString() +
                  pin3.toString() +
                  pin4.toString();
              API value;
              if (nextScreen == SignInScreen.routeName) {
                value = await apiService.verifyOTP(token: token, email: email);
              } else {
                value = await apiService.validateResetToken(
                    token: token, email: email);
              }

              // if all are valid then go to success screen
              if (value != null &&
                  value.message != null &&
                  value.message.isNotEmpty) {
                if (value.statusCode == 200) {
                  SharedPreferencesHelper.setToken(token);
                  Navigator.pushNamedAndRemoveUntil(
                      context, nextScreen, (route) => false);
                } else {
                  Toast.show(value.message, context,
                      duration: kToastDuration, gravity: Toast.BOTTOM);
                }
              }
            },
          )
        ],
      ),
    );
  }
}
