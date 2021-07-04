import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/screens/otp/otp_screen.dart';
import 'package:swabx/screens/reset_password/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:swabx/components/custom_surfix_icon.dart';
import 'package:swabx/components/default_button.dart';
import 'package:swabx/components/no_account_text.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/size_config.dart';
import 'package:toast/toast.dart';

import 'package:swabx/helper/APIService.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
          child: Column(
            children: [
              Image.asset(
                "assets/images/signup.png",
                height: getProportionateScreenHeight(200),
                width: getProportionateScreenWidth(200),
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.01),
              Text("Forgot Password", style: headingStyle),
              SizedBox(height: SizeConfig.screenHeight * 0.01),
              Text(
                "Please enter your email and we will send\nyou a One Time Password(OTP)\nto return to your account",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.04),
              ForgotPassForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPassForm extends StatefulWidget {
  @override
  _ForgotPassFormState createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  final _formKey = GlobalKey<FormState>();
  String email;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email = newValue,
            onChanged: (newValue) => email = newValue,
            validator: (value) {
              if (value.isEmpty) {
                return kEmailNullError;
              } else if (!emailValidatorRegExp.hasMatch(value)) {
                return kInvalidEmailError;
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              // If  you are using latest version of flutter then lable text and hint text shown like this
              // if you r using flutter less then 1.20.* then maybe this is not working properly
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
            ),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.04),
          DefaultButton(
            text: "Reset Password",
            press: () {
              if (_formKey.currentState.validate()) {
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtpScreen(
                                email: email,
                                nextScreen: ResetPasswordScreen.routeName),
                          ));
                    }
                  }
                });
              }
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.05),
          NoAccountText(),
        ],
      ),
    );
  }
}
