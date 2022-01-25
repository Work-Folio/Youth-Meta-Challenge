import './screens/connect_device_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const CarbonTrafficLightApp());

class CarbonTrafficLightApp extends StatelessWidget {
  const CarbonTrafficLightApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carbon Traffic Light',
      home: const ConnectDeviceScreen(),
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: const Color(0xff606060),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
