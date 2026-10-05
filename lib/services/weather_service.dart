import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherService {
  // Fonksiyonun ne döndüreceğini belirttik (Future<String>)
  Future<String> getLocation() async {
    // Kullanıcının konumu açık mı kontrol ettik
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Sadece Future.error yazmak kodu durdurmaz, 'throw Exception' kullanmalıyız
      throw Exception("Konum servisi kapali");
    }

    // Konum izni vermiş mi onu kontrol ettik
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Konum izni vermemişse tekrar izin istedik
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Konum izni vermelisiniz");
      }
    }

    // Kullanıcının pozisyonunu aldık (desiredAccuracy yerine güncel kullanım)
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    // Kullanıcı pozisyonundan yerleşim noktasını bulduk
    final List<Placemark> placemarks = await Geocoding()
        .placemarkFromCoordinates(position.latitude, position.longitude);

    // Şehrimizi yerleşim noktasından kaydettik
    final String? city = placemarks[0].locality;

    if (city == null) throw Exception("Bir sorun oluştu");

    return city;
  }
}
