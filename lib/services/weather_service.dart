import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/forecast.dart';

class WeatherService {
  final String apiKey = '02a8f38e24813413fde7358f6a2cc398';
  final String baseUrl = 'https://openweathermap.org/';

  Future<Weather> fetchWeather(String city) async {
    final data = await fetchWeatherData(city);
    return data['weather'] as Weather;
  }

  Future<Map<String, dynamic>> fetchWeatherData(String city) async {
    final encodedCity = Uri.encodeComponent(city.trim());
    final weatherUrl = Uri.parse('$baseUrl/weather?q=$encodedCity&units=metric&appid=$apiKey');
    final forecastUrl = Uri.parse('$baseUrl/forecast?q=$encodedCity&units=metric&appid=$apiKey');

    final responses = await Future.wait([
      http.get(weatherUrl),
      http.get(forecastUrl),
    ]);

    if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
      final weatherData = Weather.fromJson(jsonDecode(responses[0].body));
      
      final forecastList = jsonDecode(responses[1].body)['list'] as List;
      final forecastMap = <String, DailyForecast>{};
      
      for (var item in forecastList) {
        final dt = DateTime.parse(item['dt_txt']);
        if (dt.hour == 12) {
          final dateKey = '${dt.year}-${dt.month}-${dt.day}';
          forecastMap[dateKey] ??= DailyForecast.fromJson(item);
        }
      }
      
      return {
        'weather': weatherData,
        'forecast': forecastMap.values.toList().take(5).toList(),
      };
    } else {
      throw Exception('Gagal memuat data cuaca');
    }
  }
}
