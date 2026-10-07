import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:havadurumu/model/weather_model.dart';

class WeatherService {
  final Geocoding _geocoding = Geocoding();

  Future<String> _getLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Konum servisi kapali");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Konum izni vermelisiniz");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Konum izni kalıcı olarak reddedildi");
    }

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    final List<Placemark> placemarks = await _geocoding
        .placemarkFromCoordinates(position.latitude, position.longitude)
        .timeout(const Duration(seconds: 10));

    if (placemarks.isEmpty) throw Exception("Adres bulunamadı");
    final p = placemarks[0];
    final String? city =
        p.locality ?? p.subAdministrativeArea ?? p.administrativeArea;

    if (city == null) throw Exception("Şehir bulunamadı");
    return city;
  }

  Future<List<WeatherModel>> getWeatherData() async {
    final String city = await _getLocation();

    const Map<String, String> header = {
      'authorization': 'apikey 3D0oTFZgPCVCRueoCpewxd:1kXmsOCXXV6szXc3hdfEwv',
      'content-type': 'application/json',
    };

    final dio = Dio();
    final response = await dio.get(
      'https://api.collectapi.com/weather/getWeather',
      queryParameters: {'lang': 'tr', 'city': city},
      options: Options(headers: header),
    );
    debugPrint(response.data.toString());

    dynamic data = response.data;
    if (data is String) data = jsonDecode(data);

    // Gelen veri List ise doğrudan kullan, Map ise 'result' anahtarını al
    final List list = data is List ? data : data['result'];

    return list
        .map((e) => WeatherModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
