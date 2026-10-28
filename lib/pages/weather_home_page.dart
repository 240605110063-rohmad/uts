import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  Future<Weather>? _weatherFuture;

  void _getWeather() {
    setState(() {
      _weatherFuture = _weatherService.fetchWeather(_cityController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pelacak Cuaca')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'Masukkan Kota'),
            ),
            ElevatedButton(onPressed: _getWeather, child: const Text('Cari')),
            const SizedBox(height: 20),
            if (_weatherFuture != null)
              FutureBuilder<Weather>(
                future: _weatherFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final weather = snapshot.data!;
                    return Column(
                      children: [
                        Text(weather.cityName, style: const TextStyle(fontSize: 24)),
                        Text('${weather.temperature.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 48)),
                        Image.network('https://openweathermap.org/img/wn/${weather.icon}@2x.png'),
                        Text('Kelembapan: ${weather.humidity}%'),
                        Text('Angin: ${weather.windSpeed} m/s'),
                      ],
                    );
                  }
                  return const Text('Masukkan nama kota');
                },
              ),
          ],
        ),
      ),
    );
  }
}
