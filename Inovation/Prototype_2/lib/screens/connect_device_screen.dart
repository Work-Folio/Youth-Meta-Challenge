import 'package:carbon_traffic_light/screens/device_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './option_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ConnectDeviceScreen extends StatefulWidget {
  const ConnectDeviceScreen({Key? key}) : super(key: key);

  @override
  _ConnectDeviceScreenState createState() => _ConnectDeviceScreenState();
}

class _ConnectDeviceScreenState extends State<ConnectDeviceScreen> {
  final FlutterBluetoothSerial _bluetoothSerial = FlutterBluetoothSerial.instance;
  late final SharedPreferences _prefs;

  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _defaultOptions();
    _checkBluetooth();
  }

  void _defaultOptions() async {
    _prefs = await SharedPreferences.getInstance();
    if (!_prefs.containsKey('device_name')) {
      _prefs.setString('device_name', 'TrafficLight');
      _prefs.setDouble('electric_power', 1);
      _prefs.setDouble('yellow_level', 0.01);
      _prefs.setDouble('red_level', 0.02);
    }
  }

  Future<void> _checkBluetooth() async {
    BluetoothState state = await _bluetoothSerial.state;
    if (state == BluetoothState.STATE_OFF) {
      await _bluetoothSerial.requestEnable();
    }
  }

  void _connect() async {
    if (!_isConnecting) {
      _isConnecting = true;
      setState(() {});
      await _checkBluetooth();
      try {
        List<BluetoothDevice> devices = (await _bluetoothSerial.getBondedDevices())
            .where((device) => device.name == _prefs.getString('device_name')!).toList();
        if (devices.isNotEmpty) {
          BluetoothConnection connection = await BluetoothConnection.toAddress(devices[0].address);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceScreen(connection: connection),
            ),
          );
          Fluttertoast.showToast(msg: '연결 성공!', toastLength: Toast.LENGTH_SHORT);
        } else {
          Fluttertoast.showToast(msg: '장치를 찾을 수 없음!', toastLength: Toast.LENGTH_SHORT);
        }
      } catch (error) {
        Fluttertoast.showToast(msg: '알수없는 오류 발생!', toastLength: Toast.LENGTH_SHORT);
      }
      _isConnecting = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('연결'),
        actions: [IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OptionScreen(),
            ),
          ),
        )],
      ),
      body: Center(
        child: CircleAvatar (
          backgroundColor: Colors.grey,
          radius: 120,
          child: _isConnecting ? const SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 10,
            ),
          ) : IconButton(
            color: Colors.white,
            iconSize: 120,
            padding: const EdgeInsets.all(0),
            icon: const Icon(Icons.bluetooth),
            onPressed: () => _connect(),
          ),
        )
      ),
    );
  }
}