import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionScreen extends StatefulWidget {
  const OptionScreen({Key? key}) : super(key: key);

  @override
  _OptionScreenState createState() => _OptionScreenState();
}

class _OptionScreenState extends State<OptionScreen> {
  final TextEditingController _deviceNameInputController =
      TextEditingController();
  final TextEditingController _electricPowerInputController =
      TextEditingController();
  final TextEditingController _yellowLevelInputController =
      TextEditingController();
  final TextEditingController _redLevelInputController =
      TextEditingController();

  late final SharedPreferences _prefs;

  Widget _optionTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            color: Colors.white,
          ),
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  void _loadOptions() async {
    _prefs = await SharedPreferences.getInstance();
    _deviceNameInputController.text =
        _prefs.getString('device_name')!.toString();
    _electricPowerInputController.text =
        _prefs.getDouble('electric_power')!.toString();
    _yellowLevelInputController.text =
        _prefs.getDouble('yellow_level')!.toString();
    _redLevelInputController.text = _prefs.getDouble('red_level')!.toString();
    setState(() {});
  }

  void _saveOptions() async {
    double electricPower = double.parse(_electricPowerInputController.text);
    double yellowLevel = double.parse(_yellowLevelInputController.text);
    double redLevel = double.parse(_redLevelInputController.text);
    if (yellowLevel < redLevel) {
      _prefs.setString('device_name', _deviceNameInputController.text);
      _prefs.setDouble('electric_power', electricPower);
      _prefs.setDouble('yellow_level', yellowLevel);
      _prefs.setDouble('red_level', redLevel);
      Fluttertoast.showToast(msg: '옵션 저장 완료!', toastLength: Toast.LENGTH_SHORT);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('옵션'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _optionTextField('장치 이름', _deviceNameInputController),
          _optionTextField('소비전력 (kw)', _electricPowerInputController),
          _optionTextField('노란색 단계 탄소량 (kg)', _yellowLevelInputController),
          _optionTextField('빨간색 단계 탄소량 (kg)', _redLevelInputController),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 75,
        height: 75,
        child: FloatingActionButton(
          child: const Icon(
            Icons.save,
            size: 40,
          ),
          onPressed: () => _saveOptions(),
        ),
      ),
    );
  }
}
