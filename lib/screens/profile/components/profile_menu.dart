import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:swabx/constants.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu(
      {Key key,
      @required this.text,
      @required this.icon,
      this.press,
      this.showLeading = true})
      : super(key: key);

  final String text, icon;
  final VoidCallback press;
  final bool showLeading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      // ignore: deprecated_member_use
      child: FlatButton(
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: kSecondaryColor,
        onPressed: press,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              color: Colors.black,
              width: 22,
            ),
            SizedBox(width: 20),
            Expanded(child: Text(text)),
            Icon(showLeading ? Icons.arrow_forward_ios : null),
          ],
        ),
      ),
    );
  }
}
