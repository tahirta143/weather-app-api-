// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherData _$WeatherDataFromJson(Map<String, dynamic> json) => WeatherData(
  cityName: json['name'] as String,
  main: MainWeather.fromJson(json['main'] as Map<String, dynamic>),
  weather: (json['weather'] as List<dynamic>)
      .map((e) => Weather.fromJson(e as Map<String, dynamic>))
      .toList(),
  wind: Wind.fromJson(json['wind'] as Map<String, dynamic>),
  visibility: (json['visibility'] as num).toDouble(),
);

Map<String, dynamic> _$WeatherDataToJson(WeatherData instance) =>
    <String, dynamic>{
      'name': instance.cityName,
      'main': instance.main,
      'weather': instance.weather,
      'wind': instance.wind,
      'visibility': instance.visibility,
    };

MainWeather _$MainWeatherFromJson(Map<String, dynamic> json) => MainWeather(
  temp: (json['temp'] as num).toDouble(),
  feelsLike: (json['feels_like'] as num).toDouble(),
  pressure: (json['pressure'] as num).toInt(),
  humidity: (json['humidity'] as num).toInt(),
);

Map<String, dynamic> _$MainWeatherToJson(MainWeather instance) =>
    <String, dynamic>{
      'temp': instance.temp,
      'feels_like': instance.feelsLike,
      'pressure': instance.pressure,
      'humidity': instance.humidity,
    };

Wind _$WindFromJson(Map<String, dynamic> json) =>
    Wind(speed: (json['speed'] as num).toDouble());

Map<String, dynamic> _$WindToJson(Wind instance) => <String, dynamic>{
  'speed': instance.speed,
};

Weather _$WeatherFromJson(Map<String, dynamic> json) => Weather(
  id: (json['id'] as num).toInt(),
  main: json['main'] as String,
  description: json['description'] as String,
  icon: json['icon'] as String,
);

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
  'id': instance.id,
  'main': instance.main,
  'description': instance.description,
  'icon': instance.icon,
};
