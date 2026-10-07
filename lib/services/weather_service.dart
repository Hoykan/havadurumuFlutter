import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class WeatherService {
  // Fonksiyonun ne döndüreceğini belirttik (Future<String>)
  Future<String> getLocation() async {
    debugPrint("B) getLocation başladi");

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint("1) servis açık mı: $serviceEnabled");
    if (!serviceEnabled) {
      throw Exception("Konum servisi kapali");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint("2) izin durumu: $permission");
    if (permission == LocationPermission.denied) {
      debugPrint("3) izin isteniyor");
      permission = await Geolocator.requestPermission();
      debugPrint("4) izin sonucu: $permission");
      if (permission == LocationPermission.denied) {
        throw Exception("Konum izni vermelisiniz");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Konum izni kalıcı olarak reddedildi");
    }

    debugPrint("5) konum alınıyor");
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    debugPrint("6) konum: ${position.latitude}, ${position.longitude}");

    final List<Placemark> placemarks = await Geocoding()
        .placemarkFromCoordinates(position.latitude, position.longitude)
        .timeout(const Duration(seconds: 10));

    if (placemarks.isEmpty) throw Exception("Adres bulunamadı");
    final p = placemarks[0];
    final String? city =
        p.locality ?? p.subAdministrativeArea ?? p.administrativeArea;

    if (city == null) throw Exception("Şehir bulunamadı");
    return city;
  }
}
