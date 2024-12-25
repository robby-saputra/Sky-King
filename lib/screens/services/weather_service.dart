import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = 'YOUR_API_KEY';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/';

  static Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    final url = '${_baseUrl}weather?q=$city&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  static Future<List<dynamic>> getHourlyForecast(String city) async {
    final url = '${_baseUrl}forecast?q=$city&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['list'];
    } else {
      throw Exception('Failed to fetch forecast data');
    }
  }
}
