import 'package:flutter/material.dart';
import 'package:swabx/constants.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        leading: null, centerTitle: true, backgroundColor: kPrimaryColor);
  }

  @override
  Size get preferredSize => Size.fromHeight(35);
}
