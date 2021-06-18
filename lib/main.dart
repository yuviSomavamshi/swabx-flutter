import 'package:flutter/material.dart';
import 'helper/navigate.dart';
import 'routes.dart';
import './screens/splash/splash_screen.dart';
import 'theme.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: NavigationService.instance.navigationKey,
        debugShowCheckedModeBanner: false,
        title: kAppName,
        theme: theme(),
        // We use routeName so that we dont need to remember the name
        initialRoute: SplashScreen.routeName,
        routes: routes);
  }
}
