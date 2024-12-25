import 'package:flutter/material.dart';

class ForecastCard extends StatelessWidget {
  final List<dynamic> forecast;

  ForecastCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.length,
        itemBuilder: (context, index) {
          final item = forecast[index];
          final time = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          final temp = item['main']['temp'];
          final icon = item['weather'][0]['icon'];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${time.hour}:00'),
                Image.network('https://openweathermap.org/img/wn/$icon.png'),
                Text('${temp.toStringAsFixed(1)}°C'),
              ],
            ),
          );
        },
      ),
    );
  }
}
