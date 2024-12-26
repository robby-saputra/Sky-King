import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/api_service.dart';
import '../utils/location_service.dart';

const backgroundColorGradient = [
  Color(0xFF283E51),
  Color(0xFF4B79A1),
]; // Gradient utama latar belakang.
const cardColor = Color(0xFF34495E); // Warna dasar kartu.
const animatedGradientColors = [
  Color(0xFF1D976C),
  Color(0xFF93F9B9),
]; // Warna animasi gradient.

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic> currentWeather = {};
  List<dynamic> hourlyForecast = [];
  bool isLoading = true;
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    setupLocationAndFetchData();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  Future<void> setupLocationAndFetchData() async {
    if (await LocationService.requestLocationPermission()) {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
        await fetchWeather(position.latitude, position.longitude);
      } else {
        print('Using default location: Jakarta');
        await fetchDefaultWeather();
      }
    } else {
      print('Permission denied, using default location: Jakarta');
      await fetchDefaultWeather();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchWeather(double lat, double lon) async {
    try {
      currentWeather = await ApiService.fetchCurrentWeather(lat: lat, lon: lon);
      hourlyForecast = await ApiService.fetchHourlyForecast(lat: lat, lon: lon);
    } catch (e) {
      print('Error fetching weather data: $e');
      currentWeather = {};
      hourlyForecast = [];
    }
  }

  Future<void> fetchDefaultWeather() async {
    await fetchWeather(-6.21462, 106.84513); // Jakarta
  }

  @override
  Widget build(BuildContext context) {
    String currentDate =
    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
    String currentTime = DateFormat('HH:mm').format(DateTime.now());
    String weatherDescription = currentWeather.isNotEmpty
        ? currentWeather['weather'][0]['description']
        : 'Tidak tersedia';
    String temperature = currentWeather.isNotEmpty
        ? '${currentWeather['main']['temp']}°C'
        : 'N/A';
    String locationName = currentWeather.isNotEmpty
        ? currentWeather['name']
        : 'Lokasi tidak tersedia';

    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorTween(
                      begin: backgroundColorGradient[0],
                      end: animatedGradientColors[0])
                      .animate(_gradientController)
                      .value!,
                  ColorTween(
                      begin: backgroundColorGradient[1],
                      end: animatedGradientColors[1])
                      .animate(_gradientController)
                      .value!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              // AppBar Custom
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.menu, color: Colors.white),
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white),
                            Text(
                              locationName,
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$currentDate - $currentTime',
                          style: GoogleFonts.lato(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                    Icon(Icons.settings, color: Colors.white),
                  ],
                ),
              ),
              isLoading
                  ? Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
                  : Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Weather Section
                      AnimatedContainer(
                        duration: Duration(milliseconds: 600),
                        curve: Curves.easeInOutBack,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cuaca Saat Ini',
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  weatherDescription,
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  temperature,
                                  style: GoogleFonts.lato(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.cloud, size: 80, color: Colors.white),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Hourly Forecast Section
                      Text(
                        'Ramalan Cuaca 24 Jam',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: hourlyForecast.length,
                          itemBuilder: (context, index) {
                            final forecast = hourlyForecast[index];
                            final time = DateFormat('HH:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    forecast['dt'] * 1000));
                            final temp = forecast['main']['temp'].toString();
                            final weatherCondition =
                            forecast['weather'][0]['description'];
                            final weatherIcon =
                            forecast['weather'][0]['icon'];

                            return Transform.scale(
                              scale: 1.1,
                              child: Container(
                                width: 100,
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      cardColor.withOpacity(0.7),
                                      cardColor.withOpacity(0.9),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        time,
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Image.network(
                                        'http://openweathermap.org/img/wn/$weatherIcon@2x.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '$temp°C',
                                        style: GoogleFonts.lato(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        weatherCondition,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
