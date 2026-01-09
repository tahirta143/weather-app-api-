import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '81651739b2d402adda5fac5bf874b277';
  static String get baseUrl => dotenv.env['OPENWEATHER_BASE_URL'] ?? 'https://api.openweathermap.org/data/2.5/weather';
}