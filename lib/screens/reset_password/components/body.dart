import 'dart:async';

import 'package:swabx/components/goto_signin.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:flutter/material.dart';
import 'package:swabx/components/default_button.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/size_config.dart';
import 'package:toast/toast.dart';

import 'package:swabx/helper/APIService.dart';
import 'package:swabx/screens/sign_in/sign_in_screen.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: Column(
            children: [
              Icon(Icons.verified_user, size: 60, color: kPrimaryColor),
              SizedBox(height: SizeConfig.screenHeight * 0.01),
              Text("Reset Password", style: headingStyle),
              SizedBox(height: SizeConfig.screenHeight * 0.01),
              Text(
                "Please enter strong password",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.02),
              ResetPassForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPassForm extends StatefulWidget {
  @override
  _ResetPassFormState createState() => _ResetPassFormState();
}

class _ResetPassFormState extends State<ResetPassForm> {
  final _formKey = GlobalKey<FormState>();
  String _password;
  String _confirmPassword;

  // Initially password is obscure
  bool _obscurePassText = true;

  // Initially confirmPassword is obscure
  bool _obscureConfirmText = true;

  // Toggles the password show status
  void _togglePassField() {
    setState(() {
      _obscurePassText = !_obscurePassText;
    });
  }

  // Toggles the password show status
  void _toggleConfirmField() {
    setState(() {
      _obscureConfirmText = !_obscureConfirmText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: getProportionateScreenHeight(15)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(5)),
          buildConfirmPassFormField(),
          SizedBox(height: getProportionateScreenHeight(5)),
          DefaultButton(
            text: "Continue",
            press: () async {
              if (_formKey.currentState.validate()) {
                String token = await SharedPreferencesHelper.getUserToken();
                String email = await SharedPreferencesHelper.getUserEmail();
                APIService apiService = new APIService();
                apiService
                    .resetPassword(
                        email: email,
                        token: token,
                        password: _password,
                        confirmPassword: _confirmPassword)
                    .then((value) async {
                  // if all are valid then go to success screen
                  if (value != null &&
                      value.message != null &&
                      value.message.isNotEmpty) {
                    Toast.show(value.message, context,
                        duration: kToastDuration, gravity: Toast.BOTTOM);
                    if (value.statusCode == 200) {
                      SharedPreferencesHelper.removeString(kToken);
                      Timer(Duration(seconds: kToastDuration), () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, SignInScreen.routeName, (route) => false);
                      });
                    }
                  }
                });
              }
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.02),
          SignInText(),
          SizedBox(height: getProportionateScreenHeight(15)),
          Text("Secure Password Tips:"),
          Text(
              "Use at least 8 characters, a combination of numbers, special characters and letters\n\t\t* at least one lowercase letter.\n\t\t* at least one uppercase letter.\n\t\t* at least one number.\n\t\t* at least one of the special character !@#\$%^&\n\t",
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.caption)
        ],
      ),
    );
  }

  TextFormField buildConfirmPassFormField() {
    return TextFormField(
      obscureText: _obscureConfirmText,
      maxLength: 15,
      onSaved: (newValue) => _confirmPassword = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && _password == value) {
          _confirmPassword = value;
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          return kPassNullError;
        } else if ((_password != value)) {
          return kMatchPassError;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Confirm Password",
        hintText: "Re-enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: IconButton(
          icon: Icon(
            // Based on passwordVisible state choose the icon
            _obscureConfirmText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: _toggleConfirmField,
          padding: EdgeInsets.only(right: 20),
        ),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: _obscurePassText,
      maxLength: 15,
      onSaved: (newValue) => _password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          _password = value;
        }
      },
      validator: (value) {
        return validatePassword(value);
      },
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: IconButton(
          icon: Icon(
            // Based on passwordVisible state choose the icon
            _obscurePassText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: _togglePassField,
          padding: EdgeInsets.only(right: 20),
        ),
      ),
    );
  }
}
