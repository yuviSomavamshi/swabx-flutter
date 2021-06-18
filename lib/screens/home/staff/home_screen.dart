import 'package:flutter/material.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/models/QRCode.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:swabx/screens/home/home_screen.dart';
import 'package:swabx/screens/home/staff/register/patient_qr_scanner.dart';
import 'package:swabx/size_config.dart';

APIService apiService = new APIService();

class StaffDashboardScreen extends StatefulWidget {
  @override
  _StaffDashboardScreenState createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  QRCode myCode;

  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.getMyQR().then((value) => {
          this.setState(() {
            myCode = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: CustomAppBar(),
        body: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: <Widget>[
            buildHeader(screenHeight),
            buildTogether(screenHeight, 0.2),
            buildPreventionTips(screenHeight, 0.14),
            _MyGrid()
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, ScanPatientQRCode.routeName);
          },
          child: Icon(
            Icons.qr_code_scanner_sharp,
            color: Colors.white,
            size: 29,
          ),
          backgroundColor: kPrimaryColor,
          tooltip: 'Scan patient QR and device barcode',
          elevation: 5,
          splashColor: Colors.grey,
        ));
  }
}

class _MyGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
        padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
        sliver: SliverToBoxAdapter(
            child: Container(
          height: MediaQuery.of(context).size.height * 0.18,
          child: Column(
            children: <Widget>[
              Flexible(
                child: Row(
                  children: <Widget>[
                    _buildCard('my_staff', 'Recent Scans', context, 1),
                    _buildCard('my_locations', 'Appointments', context, 2),
                  ],
                ),
              ),
            ],
          ),
        )));
  }

  Expanded _buildCard(
      String image, String title, BuildContext context, int path) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10.0)),
        child: GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StaffHomeScreen(nextScreen: path),
                )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 10),
                Image.asset('assets/images/' + image + '.png',
                    height: 80, width: 80),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenWidth(16),
                        color: kPrimaryColor))
              ],
            )),
      ),
    );
  }
}
