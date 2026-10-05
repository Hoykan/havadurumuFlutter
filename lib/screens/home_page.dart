import 'package:flutter/material.dart';
import 'package:havadurumu/services/weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    WeatherService()
        .getLocation()
        .then((value) => print(value))
        .catchError((error) => print(error));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: []), // Column
      ), // Center
    ); // Scaffold
  }
}
