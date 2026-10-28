class DailyForecast {
  final DateTime date;
  final String description;
  final String icon;
  final double temperature;

  const DailyForecast({
    required this.date,
    required this.description,
    required this.icon,
    required this.temperature,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    return DailyForecast(
      date: DateTime.parse(json['dt_txt'] as String),
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      temperature: (main['temp'] as num).toDouble(),
    );
  }

  String get dayName {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[date.weekday - 1];
  }
}
