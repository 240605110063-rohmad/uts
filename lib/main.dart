import 'package:flutter/material.dart';
import 'models/weather.dart';
import 'models/forecast.dart';
import 'services/weather_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pelacak Cuaca',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _cityController = TextEditingController(text: 'Jakarta');
  final WeatherService _weatherService = WeatherService();
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _fetchData(_cityController.text);
  }

  void _fetchData(String city) {
    setState(() {
      _dataFuture = _weatherService.fetchWeatherData(city);
    });
  }

  void _searchWeather() {
    final query = _cityController.text.trim();
    if (query.isNotEmpty) {
      _fetchData(query);
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF42A5F5), Color(0xFF90CAF9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: TextField(
                    controller: _cityController,
                    onSubmitted: (_) => _searchWeather(),
                    decoration: InputDecoration(
                      hintText: 'Cari nama kota...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF1E88E5)),
                      suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF1E88E5)), onPressed: _searchWeather),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _dataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError) return _buildErrorWidget();
                    
                    final weather = snapshot.data!['weather'] as Weather;
                    final forecast = snapshot.data!['forecast'] as List<DailyForecast>;
                    
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Column(
                        children: [
                          _buildWeatherContent(weather),
                          const SizedBox(height: 30),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Perkiraan 5 Hari Kedepan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 12),
                          ...forecast.map((day) => _buildForecastRow(day)),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(Weather weather) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(weather.cityName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        Image.network('https://openweathermap.org/img/wn/${weather.icon}@4x.png', width: 120, height: 120),
        Text('${weather.temperature.round()}°C', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(weather.description.toUpperCase(), style: const TextStyle(fontSize: 18, color: Colors.white70, letterSpacing: 2.0)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeatherDetailItem(icon: Icons.water_drop_outlined, value: '${weather.humidity}%', label: 'Kelembapan'),
              Container(height: 48, width: 1, color: Colors.white.withValues(alpha: 0.35)),
              _buildWeatherDetailItem(icon: Icons.air_rounded, value: '${weather.windSpeed} m/s', label: 'Angin'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForecastRow(DailyForecast forecast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 80, child: Text(forecast.dayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Image.network('https://openweathermap.org/img/wn/${forecast.icon}.png', width: 40),
          Expanded(child: Text(forecast.description, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center)),
          Text('${forecast.temperature.round()}°C', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailItem({required IconData icon, required String value, required String label}) {
    return Column(children: [Icon(icon, color: Colors.white, size: 30), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)), Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70))]);
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 80, color: Colors.white),
          const SizedBox(height: 20),
          const Text('Ups, kota tidak ditemukan!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _searchWeather, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
