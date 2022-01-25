import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key, required this.connection}) : super(key: key);

  final BluetoothConnection connection;

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final Stopwatch _swatch = Stopwatch();
  late Timer _timer;
  bool _isOptionsLoad = false;
  late final double _electricPower;
  late final double _yellowLevel;
  late final double _redLevel;
  MaterialColor _color = Colors.green;
  
  @override
  void initState() {
    super.initState();
    _loadOptions();
    _startSwatch();
    _sendCommand('g');
  }

  @override
  void dispose() {
    _stopSwatch();
    _disconnect();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _electricPower = prefs.getDouble('electric_power')!;
    _yellowLevel = prefs.getDouble('yellow_level')!;
    _redLevel = prefs.getDouble('red_level')!;
    _isOptionsLoad = true;
  }

  void _disconnect() async {
    if (widget.connection.isConnected) {
      await widget.connection.close();
    }
  }

  void _sendCommand(String command) {
    if (widget.connection.isConnected) {
      widget.connection.output.add(Uint8List.fromList(utf8.encode(command + '\r\n')));
    }
  }

  void _startSwatch() {
    if (!_swatch.isRunning) {
      _swatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => setState(() {}));
    }
  }

  void _stopSwatch() {
    if (_swatch.isRunning) {
      _swatch.stop();
      _timer.cancel();
    }
  }

  double _getCarbon() {
    double carbon =  _electricPower / 3600 * _swatch.elapsed.inSeconds * 0.424;
    if (_color == Colors.green && carbon >= _yellowLevel) {
      _sendCommand('y');
      _color = Colors.yellow;
    }
    if (_color == Colors.yellow && carbon >= _redLevel) {
      _sendCommand('r');
      _color = Colors.red;
    }
    return carbon;
  }

  String _getSwatchTime() => '${_swatch.elapsed.inHours.toString().padLeft(2,'0')} : ${(_swatch.elapsed.inMinutes%60).toString().padLeft(2, '0')} : ${(_swatch.elapsed.inSeconds%60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _color,
      appBar: AppBar(
        title: const Text('측정'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: _isOptionsLoad ? Text (
                '${_getCarbon().toStringAsFixed(5)} Kg',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                ),
              ) : const Text (
                '0 Kg',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                ),
              ),
            ),
            Text(
              _getSwatchTime(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
          ],
        ),
      )
    );
  }
}
