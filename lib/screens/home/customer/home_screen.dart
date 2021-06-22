import 'package:flutter/material.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:swabx/size_config.dart';
import '../home_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
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
        ));
  }
}

class _MyGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        sliver: SliverToBoxAdapter(
            child: Container(
          height: MediaQuery.of(context).size.height * 0.15,
          child: Column(
            children: <Widget>[
              Flexible(
                child: Row(
                  children: <Widget>[
                    _buildCard('my_staff', 'My Staff', context, 1),
                    _buildCard('my_locations', 'My Locations', context, 2),
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
                  builder: (context) => CustomerHomeScreen(nextScreen: path),
                )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/' + image + '.png',
                    height: getProportionateScreenHeight(50),
                    width: getProportionateScreenWidth(50)),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenWidth(16),
                        color: kPrimaryColor)),
              ],
            )),
      ),
    );
  }
}
