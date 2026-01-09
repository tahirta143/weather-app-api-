import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  Future<Position> getCurrentLocation() async {
    // Check permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  Future<String> getCityName(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/geo/1.0/reverse?'
              'lat=$lat&lon=$lon&limit=1&appid=81651739b2d402adda5fac5bf874b277',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final city = data[0]['name'] ?? 'Unknown';
          final country = data[0]['country'] ?? '';
          return '$city, $country';
        }
      }
    } catch (e) {
      print('Error getting city name: $e');
    }

    return 'Unknown Location';
  }

  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/geo/1.0/direct?'
              'q=$query&limit=5&appid=81651739b2d402adda5fac5bf874b277',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data.map((item) => {
          'name': item['name'],
          'country': item['country'],
          'state': item['state'],
          'lat': item['lat'],
          'lon': item['lon'],
          'displayName': '${item['name']}, ${item['country']}',
        }));
      }
    } catch (e) {
      print('Error searching cities: $e');
    }

    return [];
  }
}