import 'package:json_annotation/json_annotation.dart';

part 'weather_model.g.dart';

@JsonSerializable()
class WeatherData {
  @JsonKey(name: 'name')
  final String cityName;

  @JsonKey(name: 'main')
  final MainWeather main;

  final List<Weather> weather;

  final Wind wind;

  @JsonKey(name: 'visibility') // Add visibility
  final double visibility;

  WeatherData({
    required this.cityName,
    required this.main,
    required this.weather,
    required this.wind,
    required this.visibility,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherDataToJson(this);

  // ✅ UI helpers
  double get temperature => main.temp;
  double get feelsLike => main.feelsLike;
  double get humidity => main.humidity.toDouble(); // convert int → double
  double get pressure => main.pressure.toDouble(); // convert int → double
  double get windSpeed => wind.speed;

  String get condition =>
      weather.isNotEmpty ? weather[0].main : 'Clear';

  String get description =>
      weather.isNotEmpty ? weather[0].description : 'clear sky';

  String get icon =>
      weather.isNotEmpty ? weather[0].icon : '01d';
}

@JsonSerializable()
class MainWeather {
  final double temp;

  @JsonKey(name: 'feels_like')
  final double feelsLike;

  final int pressure;
  final int humidity;

  MainWeather({
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
  });

  factory MainWeather.fromJson(Map<String, dynamic> json) =>
      _$MainWeatherFromJson(json);

  Map<String, dynamic> toJson() => _$MainWeatherToJson(this);
}

@JsonSerializable()
class Wind {
  final double speed;

  Wind({required this.speed});

  factory Wind.fromJson(Map<String, dynamic> json) =>
      _$WindFromJson(json);

  Map<String, dynamic> toJson() => _$WindToJson(this);
}

@JsonSerializable()
class Weather {
  final int id;
  final String main;
  final String description;
  final String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherToJson(this);
}
