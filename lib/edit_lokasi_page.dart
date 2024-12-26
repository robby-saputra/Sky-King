import 'package:flutter/material.dart';
import 'dart:convert'; // Untuk mengolah JSON
import 'package:http/http.dart' as http;

class EditLokasiPage extends StatefulWidget {
  @override
  _EditLokasiPageState createState() => _EditLokasiPageState();
}

class _EditLokasiPageState extends State<EditLokasiPage> {
  final TextEditingController _locationController = TextEditingController();
  final List<Map<String, String>> _savedLocations = [];

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<String> _fetchWeather(String location) async {
    const apiKey = '164f982fe0ad2c869d4073bf3c020895'; // Ganti dengan API key Anda
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey&units=metric&lang=id';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temperature = data['main']['temp'];
        final description = data['weather'][0]['description'];
        return 'Suhu: ${temperature}°C, $description';
      } else {
        return 'Lokasi tidak ditemukan.';
      }
    } catch (e) {
      return 'Kesalahan: Tidak dapat mengambil data cuaca.';
    }
  }

  void _saveLocation() async {
    final newLocation = _locationController.text.trim();

    if (newLocation.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      final weatherInfo = await _fetchWeather(newLocation);

      Navigator.pop(context);

      if (weatherInfo.contains('Kesalahan') || weatherInfo.contains('Lokasi tidak ditemukan')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(weatherInfo)),
        );
      } else {
        setState(() {
          _savedLocations.add({
            'location': newLocation,
            'weather': weatherInfo,
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lokasi berhasil ditambahkan: $newLocation')),
        );

        _locationController.clear();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lokasi tidak boleh kosong')),
      );
    }
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Penghapusan'),
        content: Text('Apakah Anda yakin ingin menghapus lokasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteLocation(index);
              Navigator.pop(context);
            },
            child: Text('Hapus'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _deleteLocation(int index) {
    setState(() {
      _savedLocations.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lokasi berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Edit Lokasi'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input lokasi
            Text(
              'Masukkan lokasi baru:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _locationController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Lokasi',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.location_on, color: Colors.white70),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveLocation,
              icon: Icon(Icons.save),
              label: Text('Simpan Lokasi'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 30),
            // Daftar lokasi
            Text(
              'Daftar Lokasi:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _savedLocations.isEmpty
                  ? Center(
                child: Text(
                  'Belum ada lokasi yang disimpan.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: _savedLocations.length,
                itemBuilder: (context, index) {
                  final location = _savedLocations[index]['location'];
                  final weather = _savedLocations[index]['weather'];

                  return Card(
                    color: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.location_on, color: Colors.white),
                      ),
                      title: Text(location ?? '', style: TextStyle(color: Colors.white)),
                      subtitle: Text(weather ?? '', style: TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(index),
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
