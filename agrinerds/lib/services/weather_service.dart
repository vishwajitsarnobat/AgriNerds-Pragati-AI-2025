import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  static const String baseUrl = 'https://api.open-meteo.com/v1';

  Future<WeatherData> getWeatherData(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,visibility&timezone=auto'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        if (jsonData['current'] == null) {
          throw Exception('Invalid weather data format');
        }
        return WeatherData.fromJson(jsonData);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  Future<Map<String, dynamic>> getForecast(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m,precipitation_probability,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_sum&timezone=auto',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching forecast data: $e');
    }
  }
} 