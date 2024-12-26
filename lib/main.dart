import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import './edit_lokasi_page.dart';



void main() {
  initializeDateFormatting('id_ID', null).then((_) {
    runApp(MyApp());
  });
}

const backgroundColor = Color(0xFF283593);
const cardColor = Color(0xFF3949AB);
const appBarColor = Color(0xFF1A237E);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sky King',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String locationName = "Tangerang";
  List<dynamic> hourlyForecast = [];
  Map<String, dynamic> currentWeather = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setupLocationAndFetchData();
  }

  Future<void> setupLocationAndFetchData() async {
    try {
      if (await requestLocationPermission()) {
        Position position = await Geolocator.getCurrentPosition();
        await fetchCurrentWeather(lat: position.latitude, lon: position.longitude);
        await fetchHourlyForecast(lat: position.latitude, lon: position.longitude);
        await fetchLocationName(position.latitude, position.longitude);
      } else {
        double defaultLat = -6.21462; // Default Jakarta
        double defaultLon = 106.84513;
        await fetchCurrentWeather(lat: defaultLat, lon: defaultLon);
        await fetchHourlyForecast(lat: defaultLat, lon: defaultLon);
        await fetchLocationName(defaultLat, defaultLon);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  Future<void> fetchLocationName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      setState(() {
        locationName = placemarks.first.locality ?? "Tidak diketahui";
      });
    } catch (e) {
      print('Gagal mendapatkan nama lokasi: $e');
    }
  }

  Future<void> fetchCurrentWeather({required double lat, required double lon}) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=164f982fe0ad2c869d4073bf3c020895&units=metric&lang=id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          currentWeather = jsonDecode(response.body);
        });
      } else {
        print('Gagal mengambil data cuaca saat ini: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

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
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String mapWeatherDescription(String description) {
    Map<String, String> weatherDescriptions = {
      'berawan': 'Berawan',
      'langit cerah': 'Langit Cerah',
      'sedikit berawan': 'Sedikit Berawan',
      'berawan seperlunya': 'Berawan Seperlunya',
      'awan tebal': 'Awan Tebal',
      'awan pecah': 'Awan Pecah',
      'awan mendung': 'Awan Mendung',
      'hujan deras': 'Hujan Deras',
      'hujan ringan': 'Hujan Ringan',
      'hujan sedang': 'Hujan Sedang',
      'hujan': 'Hujan',
      'badai petir': 'Badai Petir',
      'salju': 'Salju',
      'kabut': 'Kabut',
    };

    return weatherDescriptions[description.toLowerCase()] ?? 'Cuaca Tidak Diketahui';
  }

  Widget buildHourlyForecast() {
    void showEditLocationDialog() {
      TextEditingController locationController = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Lokasi'),
            content: TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama lokasi',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                child: Text('Batal'),
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog tanpa aksi
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () async {
                  String newLocation = locationController.text.trim();
                  if (newLocation.isNotEmpty) {
                    Navigator.of(context).pop(); // Tutup dialog
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      List<Location> locations = await locationFromAddress(newLocation);
                      if (locations.isNotEmpty) {
                        double lat = locations.first.latitude;
                        double lon = locations.first.longitude;

                        await fetchCurrentWeather(lat: lat, lon: lon);
                        await fetchHourlyForecast(lat: lat, lon: lon);

                        setState(() {
                          locationName = newLocation;
                          isLoading = false;
                        });
                      }
                    } catch (e) {
                      print('Gagal menemukan lokasi: $e');
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
              ),
            ],
          );
        },
      );
    }


    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: hourlyForecast.map((item) {
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          String time = DateFormat('HH:mm').format(dateTime);
          String temperature = '${item['main']['temp']}°C';
          String weatherIcon = item['weather'][0]['icon'];

          return Card(
            color: cardColor,
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),

              child: Column(
                children: [
                  Text(time, style: TextStyle(color: Colors.white, fontSize: 16)),
                  Image.network('https://openweathermap.org/img/wn/$weatherIcon@2x.png', height: 40),
                  Text(temperature, style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
    String currentTime = DateFormat('HH:mm').format(DateTime.now());
    String weatherDescription = currentWeather.isNotEmpty
        ? mapWeatherDescription(currentWeather['weather'][0]['description'])
        : 'Tidak tersedia';
    String temperature = currentWeather.isNotEmpty
        ? '${currentWeather['main']['temp']}°C'
        : 'N/A';
    String windSpeed = currentWeather.isNotEmpty
        ? '${currentWeather['wind']['speed']} m/s'
        : 'N/A';
    String humidity = currentWeather.isNotEmpty
        ? '${currentWeather['main']['humidity']}%'
        : 'N/A';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: Colors.white),
                Text(
                  locationName,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              '$currentDate - $currentTime',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white), // Ikon burger
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Membuka drawer
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              await setupLocationAndFetchData();
            },
          ),
        ],
      ),

      // Tambahkan drawer di sini
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: appBarColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sky King',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Weather App',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Menutup drawer tanpa aksi tambahan
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Edit lokasi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditLokasiPage()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                // Aksi untuk About
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Sky King',
                  applicationVersion: '1.0.0',
                  children: [Text('Aplikasi cuaca sederhana untuk memantau kondisi cuaca terkini.')],
                );
              },
            ),



          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: setupLocationAndFetchData,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cuaca Saat Ini',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  temperature,
                                  style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  weatherDescription,
                                  style: TextStyle(color: Colors.white70, fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.wb_sunny, color: Colors.orange, size: 48),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Angin: $windSpeed', style: TextStyle(color: Colors.white)),
                          Text('Kelembapan: $humidity', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Ramalan Cuaca per Jam',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              buildHourlyForecast(),



            ],
          ),
        ),
      ),
    );
  }

}