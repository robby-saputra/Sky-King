import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class LihatCuacaPage extends StatefulWidget {
  final String location;
  final String weather;
  final double temperature;
  final int humidity;
  final double windSpeed;

  LihatCuacaPage({
    required this.location,
    required this.weather,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
  });

  @override
  _LihatCuacaPageState createState() => _LihatCuacaPageState();
}

class _LihatCuacaPageState extends State<LihatCuacaPage> {
  List<dynamic> hourlyForecast = [];

  // Fungsi untuk mengambil ramalan cuaca per jam
  Future<void> fetchHourlyForecast({required double lat, required double lon}) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=164f982fe0ad2c869d4073bf3c020895&units=metric&lang=id');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          hourlyForecast = data['list']; // Ambil semua data ramalan tanpa filter
        });
      } else {
        print('Gagal mengambil data ramalan cuaca: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data ramalan cuaca.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan: Tidak dapat mengambil data cuaca.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Gantilah dengan koordinat yang sesuai untuk lokasi Anda
    double latitude = -6.2088;  // Contoh: Koordinat Jakarta
    double longitude = 106.8456;
    fetchHourlyForecast(lat: latitude, lon: longitude); // Panggil fungsi untuk mengambil data ramalan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF283593),
      appBar: AppBar(
        title: Text(
          widget.location,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1A237E),
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cuaca saat ini:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              widget.weather,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Text(
              '${widget.temperature}°C',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Kelembapan: ${widget.humidity}%',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Text(
              'Kecepatan Angin: ${widget.windSpeed} m/s',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Prediksi Cuaca 24 Jam:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            Expanded(
              child: hourlyForecast.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: hourlyForecast.length,
                itemBuilder: (context, index) {
                  final hourData = hourlyForecast[index];
                  final temperature = hourData['main']['temp'];
                  final weatherDescription = hourData['weather'][0]['description'];
                  final windSpeed = hourData['wind']['speed'];
                  final humidity = hourData['main']['humidity'];
                  final time = DateTime.fromMillisecondsSinceEpoch(hourData['dt'] * 1000);

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[700]!, Colors.blue[900]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          offset: Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(Icons.access_time, color: Colors.white),
                      title: Text(
                        '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$weatherDescription',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            'Suhu: ${temperature}°C',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            'Kelembapan: ${humidity}%',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            'Kecepatan Angin: ${windSpeed} m/s',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
