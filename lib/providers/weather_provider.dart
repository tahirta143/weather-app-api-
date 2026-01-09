import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_api.dart'; // Your API service

class WeatherProvider with ChangeNotifier {
  WeatherData? _weatherData;
  WeatherData? get weatherData => _weatherData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  String _currentLocation = 'Lahore, Pakistan';
  String get currentLocation => _currentLocation;

  final List<String> popularCities = [
    'Lahore, Pakistan',
    'Multan, Pakistan',
    'Islamabad, Pakistan',
    'Kasur, Pakistan',
    'Raiwind, Pakistan',
    'Karachi, Pakistan',
  ];

  WeatherProvider() {
    fetchWeatherByCity(_currentLocation);
  }

  Future<void> fetchWeatherByCity(String city) async {
    _setLoading(true);
    try {
      // Replace this with your actual API call
      _weatherData = await WeatherService().getWeatherByCityName(city);
      _currentLocation = city;
      _error = '';
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> fetchWeatherByLocation() async {
    await fetchWeatherByCity('Lahore, Pakistan'); // Default
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /* ================= UI HELPERS ================= */

  CurrentWeatherSummary? getCurrentWeather() {
    if (_weatherData == null) return null;
    return CurrentWeatherSummary(
      temperature: _weatherData!.temperature,
      feelsLike: _weatherData!.feelsLike,
      windSpeed: _weatherData!.windSpeed,
      humidity: _weatherData!.humidity,
      visibility: _weatherData!.visibility,
      pressure: _weatherData!.pressure,
      condition: _weatherData!.condition,
      icon: _weatherData!.icon,
    );
  }

  List<HourlyForecastUI> getHourlyForecast() {
    if (_weatherData == null) return [];
    return List.generate(12, (i) {
      return HourlyForecastUI(
        time: DateTime.now().add(Duration(hours: i + 1)),
        temperature: _weatherData!.temperature,
        icon: _weatherData!.icon,
        condition: _weatherData!.condition,
        precipitation: 10,
      );
    });
  }

  List<DailyForecastUI> getDailyForecast() {
    if (_weatherData == null) return [];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(7, (i) {
      return DailyForecastUI(
        day: days[i],
        maxTemp: _weatherData!.temperature + i,
        minTemp: _weatherData!.temperature - i,
        icon: _weatherData!.icon,
        condition: _weatherData!.condition,
        precipitation: i * 5.0,
      );
    });
  }
}

/* ================= UI MODELS ================= */

class CurrentWeatherSummary {
  final double temperature;
  final double feelsLike;
  final double windSpeed;
  final double humidity;
  final double visibility;
  final double pressure;
  final String condition;
  final String icon;

  CurrentWeatherSummary({
    required this.temperature,
    required this.feelsLike,
    required this.windSpeed,
    required this.humidity,
    required this.visibility,
    required this.pressure,
    required this.condition,
    required this.icon,
  });
}

class HourlyForecastUI {
  final DateTime time;
  final double temperature;
  final String condition;
  final String icon;
  final double precipitation;

  HourlyForecastUI({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.precipitation,
  });
}

class DailyForecastUI {
  final String day;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final String icon;
  final double precipitation;

  DailyForecastUI({
    required this.day,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.icon,
    required this.precipitation,
  });
}
