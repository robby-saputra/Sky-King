import 'dart:convert'; // Library untuk konversi data JSON
import 'package:flutter/material.dart'; // Library utama Flutter
import 'package:http/http.dart' as http; // Library untuk HTTP request

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Menambahkan parameter opsional 'key' dan meneruskannya ke constructor induk
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sky King',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema aplikasi
      ),
      home: const WeatherScreen(), // Gunakan konstanta untuk widget tanpa state
    );
  }
}

class WeatherScreen extends StatefulWidget {
  // Menambahkan parameter opsional 'key' dan meneruskannya ke constructor induk
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  String _city = 'London'; // Nama kota default
  String _temperature = ''; // Menyimpan suhu
  String _weatherDescription = ''; // Menyimpan deskripsi cuaca
  String _icon = ''; // Menyimpan ikon cuaca

  // API Key untuk akses data cuaca
  final String _apiKey = '164f982fe0ad2c869d4073bf3c020895';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  // Fungsi untuk mengambil data cuaca
  Future<void> _fetchWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$_city&appid=$_apiKey&units=metric';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = data['main']['temp'].toString();
          _weatherDescription = data['weather'][0]['description'];
          _icon = data['weather'][0]['icon'];
        });
      } else {
        // Debugging dengan debugPrint
        debugPrint('Error fetching weather data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sky King'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Cuaca di $_city',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _temperature != ''
                ? Column(
              children: [
                Image.network(
                    'https://openweathermap.org/img/wn/$_icon@2x.png'),
                Text(
                  '$_temperature °C',
                  style: const TextStyle(fontSize: 50),
                ),
                Text(
                  _weatherDescription,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            )
                : const CircularProgressIndicator(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _city = 'Jakarta'; // Ubah nama kota sesuai keinginan
                });
                _fetchWeather();
              },
              child: const Text('Cek Cuaca di Jakarta'),
            ),
          ],
        ),
      ),
    );
  }
}
