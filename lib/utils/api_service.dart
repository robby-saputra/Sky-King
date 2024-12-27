import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = '164f982fe0ad2c869d4073bf3c020895';
const String baseUrl = 'http://api.openweathermap.org/data/2.5';

/// Mendapatkan cuaca saat ini berdasarkan koordinat
class ApiService {
  static Future<Map<String, dynamic>> fetchCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load current weather');
    }
  }

  /// Mendapatkan prakiraan cuaca per jam berdasarkan koordinat
  static Future<List<dynamic>> fetchHourlyForecast({
    required double lat,
    required double lon,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['list']; // Mengembalikan daftar ramalan per jam
    } else {
      throw Exception('Failed to load hourly forecast');
    }
  }
}
