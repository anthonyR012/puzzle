import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = const MethodChannel('com.example/timezone');
  String _timezoneSetting = 'Unknown';

  @override
  void initState() {
    super.initState();
    _getTimezoneSetting();
  }

  Future<void> _getTimezoneSetting() async {
    String timezoneSetting;
    try {
      final result = await platform.invokeMethod('isAutoTimeZoneEnabled');
      if(result.runtimeType == bool){
        timezoneSetting = result ? 'Enabled' : 'Disabled';
      }else{
        timezoneSetting = result.toString();
      }
    } catch (e) {
      timezoneSetting = 'Failed to get the timezone setting.';
    }

    if (!mounted) return;

    setState(() {
      _timezoneSetting = timezoneSetting;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración de Zona Horaria'),
      ),
      body: Center(
        child: Text('Actualización automática de zona horaria: $_timezoneSetting'),
      ),
    );
  }
}