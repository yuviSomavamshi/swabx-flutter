import 'package:flutter/material.dart';

import 'components/body.dart';

class ChangePasswordScreen extends StatelessWidget {
  static String routeName = "/change_password";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text("Change Password"),
          centerTitle: true),
      body: Body(),
    );
  }
}
