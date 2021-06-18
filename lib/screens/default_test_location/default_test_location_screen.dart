import 'package:flutter/material.dart';

import 'components/body.dart';

class DefaultTestLocation extends StatelessWidget {
  static String routeName = "/default_test_location";
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
          title: Text("Default Test Location"),
          centerTitle: true),
      body: Body(),
    );
  }
}
