import 'package:flutter/material.dart';
import 'components/body.dart';

class ProfileScreen extends StatelessWidget with PreferredSizeWidget {
  static String routeName = "/profile";
  @override
  Widget build(BuildContext context) {
    return Body();
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}
