import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sky King',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _city = 'London'; // Nama kota default
  String _temperature = '';
  String _weatherDescription = '';
  String _icon = '';

  // Ganti dengan API Key Anda
  final String _apiKey = '164f982fe0ad2c869d4073bf3c020895';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$_city&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _temperature = data['main']['temp'].toString();
        _weatherDescription = data['weather'][0]['description'];
        _icon = data['weather'][0]['icon'];
      });
    } else {
      // Tangani jika permintaan gagal
      print('Error fetching weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sky King'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Cuaca di $_city',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _temperature != ''
                ? Column(
              children: [
                Image.network('https://openweathermap.org/img/wn/$_icon@2x.png'),
                Text(
                  '$_temperature °C',
                  style: TextStyle(fontSize: 50),
                ),
                Text(
                  _weatherDescription,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            )
                : CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _city = 'Jakarta';  // Ubah nama kota sesuai keinginan
                });
                _fetchWeather();
              },
              child: Text('Cek Cuaca di Jakarta1'),
            ),
          ],
        ),
      ),
    );
  }
}
