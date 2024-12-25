import 'package:flutter/material.dart';

class WeatherInfo extends StatelessWidget {
  final Map<String, dynamic> weather;

  WeatherInfo({required this.weather});

  @override
  Widget build(BuildContext context) {
    final temp = weather['main']['temp'];
    final description = weather['weather'][0]['description'];
    final icon = weather['weather'][0]['icon'];

    return Column(
      children: [
        Text(
          '${temp.toStringAsFixed(1)}°C',
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
        ),
        Text(
          description.toUpperCase(),
          style: TextStyle(fontSize: 18),
        ),
        Image.network('https://openweathermap.org/img/wn/$icon@2x.png'),
      ],
    );
  }
}
