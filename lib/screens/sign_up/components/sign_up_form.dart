import 'package:swabx/screens/sign_in/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:swabx/components/custom_surfix_icon.dart';
import 'package:swabx/components/default_button.dart';
import 'package:swabx/screens/otp/otp_screen.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:toast/toast.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/size_config.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String name;
  String email;
  bool remember = false;
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
          buildFirstNameFormField(),
          SizedBox(height: getProportionateScreenHeight(10)),
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(5)),
          buildConfirmPassFormField(),
          SizedBox(height: getProportionateScreenHeight(5)),
          DefaultButton(
            text: "Continue",
            press: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                APIService apiService = new APIService();
                apiService
                    .signup(name: name, email: email, password: _password)
                    .then((value) {
                  // if all are valid then go to success screen
                  if (value != null && value.message.isNotEmpty) {
                    Toast.show(value.message, context,
                        duration: kToastDuration, gravity: Toast.BOTTOM);
                    if (value.statusCode == 200) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtpScreen(
                                email: email,
                                nextScreen: SignInScreen.routeName),
                          ));
                    }
                  }
                });
              }
            },
          ),
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
        if (value.isNotEmpty && _password == _confirmPassword) {
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

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && emailValidatorRegExp.hasMatch(value)) {
          email = value;
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty && !emailValidatorRegExp.hasMatch(value)) {
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
    );
  }

  TextFormField buildFirstNameFormField() {
    return TextFormField(
      maxLength: 25,
      onSaved: (newValue) => name = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          name = value;
        }
        return null;
      },
      validator: (value) {
        return validateName(value);
      },
      decoration: InputDecoration(
        labelText: "Your Name",
        hintText: "Enter your name",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }
}
