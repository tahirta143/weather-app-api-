import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = '81651739b2d402adda5fac5bf874b277';

  /// 🌍 Get weather using latitude & longitude (FREE API)
  Future<WeatherData> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather'
            '?lat=$lat'
            '&lon=$lon'
            '&units=metric'
            '&appid=$_apiKey',
      );

      print('Fetching weather from: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Weather data received successfully');
        return WeatherData.fromJson(data);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('WeatherService error: $e');
      throw Exception('Failed to load weather data: $e');
    }
  }

  /// 🏙 Get weather using city name
  Future<WeatherData> getWeatherByCityName(String cityName) async {
    try {
      print('Fetching coordinates for: $cityName');

      final geoUrl = Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct'
            '?q=$cityName'
            '&limit=1'
            '&appid=$_apiKey',
      );

      final geoResponse =
      await http.get(geoUrl).timeout(const Duration(seconds: 30));

      if (geoResponse.statusCode == 200) {
        final geoData = json.decode(geoResponse.body);

        if (geoData.isNotEmpty) {
          final lat = (geoData[0]['lat'] as num).toDouble();
          final lon = (geoData[0]['lon'] as num).toDouble();

          print('Coordinates found: lat=$lat, lon=$lon');
          return await getWeatherByCoordinates(lat, lon);
        } else {
          throw Exception('City not found: $cityName');
        }
      } else {
        throw Exception(
          'Failed to get city coordinates: ${geoResponse.statusCode}',
        );
      }
    } catch (e) {
      print('City search error: $e');
      throw Exception('Failed to find city: $e');
    }
  }
}
