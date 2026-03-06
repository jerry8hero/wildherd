import 'package:flutter/material.dart';
import '../../data/models/weather.dart';
import '../../data/services/weather_service.dart';
import '../../data/services/feeding_recommendation_service.dart';
import '../../data/local/user_preferences.dart';

class FeedingWeatherScreen extends StatefulWidget {
  final String? speciesType;

  const FeedingWeatherScreen({super.key, this.speciesType});

  @override
  State<FeedingWeatherScreen> createState() => _FeedingWeatherScreenState();
}

class _FeedingWeatherScreenState extends State<FeedingWeatherScreen> {
  // 手动输入的天气数据
  double _inputTemp = 25;
  double _inputHumidity = 60;
  bool _isManualMode = false; // 默认自动模式
  WeatherData? _currentWeather;
  List<ForecastDay>? _forecast;
  String _selectedCity = '北京';

  @override
  void initState() {
    super.initState();
    _selectedCity = UserPreferences.getCityName();
    _initWeather();
  }

  Future<void> _initWeather() async {
    final weather = await _getNetworkWeather();
    if (weather != null) {
      setState(() {
        _currentWeather = weather;
        _forecast = weather.forecast;
        _isManualMode = false;
      });
    }
  }

  Future<WeatherData?> _getNetworkWeather() async {
    // 使用WeatherService获取真实天气数据
    return await WeatherService.getFullWeather();
  }

  void _updateManualWeather() {
    setState(() {
      _currentWeather = ManualWeatherService.createManualWeather(
        temperature: _inputTemp,
        humidity: _inputHumidity,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final weather = _currentWeather ?? ManualWeatherService.createManualWeather(
      temperature: _inputTemp,
      humidity: _inputHumidity,
    );

    final recommendation = FeedingRecommendationService.getRecommendationFromWeather(
      weather,
      speciesType: widget.speciesType,
    );

    final reminders = FeedingRecommendationService.generateReminders(
      currentWeather: weather,
      forecast: _forecast,
      speciesType: widget.speciesType,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('喂食天气'),
        actions: [
          IconButton(
            icon: Icon(_isManualMode ? Icons.cloud_off : Icons.cloud),
            onPressed: () {
              setState(() {
                _isManualMode = !_isManualMode;
                if (!_isManualMode) {
                  _initWeather();
                }
              });
            },
            tooltip: _isManualMode ? '自动获取天气' : '手动输入',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前天气卡片
            _buildCurrentWeatherCard(weather, recommendation),
            const SizedBox(height: 16),

            // 手动输入区域
            if (_isManualMode) _buildManualInput(),

            // 喂食提醒
            if (reminders.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildRemindersCard(reminders),
            ],

            // 未来天气预报
            if (_forecast != null && _forecast!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildForecastCard(_forecast!),
            ],

            // 温度与喂食关系说明
            const SizedBox(height: 16),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard(WeatherData weather, FeedingRecommendation recommendation) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 城市选择器
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: UserPreferences.popularCities.keys.map((city) {
                      return DropdownMenuItem(value: city, child: Text(city));
                    }).toList(),
                    onChanged: (city) async {
                      if (city != null) {
                        await UserPreferences.setCity(city);
                        setState(() => _selectedCity = city);
                        _initWeather(); // 重新获取天气
                      }
                    },
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                Icon(
                  _getWeatherIconData(weather.iconName),
                  size: 48,
                  color: _getWeatherIconColor(weather.iconName),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}°C',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '湿度: ${weather.humidity.toStringAsFixed(0)}%',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // 喂食推荐
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: recommendation.canFeed
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    recommendation.canFeed ? Icons.check_circle : Icons.warning,
                    color: recommendation.canFeed ? Colors.green : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: recommendation.canFeed ? Colors.green : Colors.red,
                          ),
                        ),
                        Text(
                          recommendation.reason,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (recommendation.warning != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            recommendation.warning!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit, size: 20),
                const SizedBox(width: 8),
                Text(
                  '手动输入当前温度',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 温度滑块
            Row(
              children: [
                const Text('温度: '),
                Expanded(
                  child: Slider(
                    value: _inputTemp,
                    min: 10,
                    max: 40,
                    divisions: 60,
                    label: '${_inputTemp.toStringAsFixed(1)}°C',
                    onChanged: (value) {
                      setState(() {
                        _inputTemp = value;
                        _updateManualWeather();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${_inputTemp.toStringAsFixed(1)}°C',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            // 湿度滑块
            Row(
              children: [
                const Text('湿度: '),
                Expanded(
                  child: Slider(
                    value: _inputHumidity,
                    min: 20,
                    max: 100,
                    divisions: 80,
                    label: '${_inputHumidity.toStringAsFixed(0)}%',
                    onChanged: (value) {
                      setState(() {
                        _inputHumidity = value;
                        _updateManualWeather();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${_inputHumidity.toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersCard(List<String> reminders) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '喂食提醒',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...reminders.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(r),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastCard(List<ForecastDay> forecast) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(
                  '未来天气预报',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...forecast.map((day) {
              final rec = day.feedingRecommendation;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${day.date.month}/${day.date.day}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      _getWeatherIconData(_getWeatherIcon(day.condition)),
                      size: 20,
                      color: _getWeatherIconColor(_getWeatherIcon(day.condition)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${day.minTemp.toStringAsFixed(0)}° - ${day.maxTemp.toStringAsFixed(0)}°C',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: rec.canFeed ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rec.canFeed ? '可喂食' : '不建议',
                        style: TextStyle(
                          fontSize: 12,
                          color: rec.canFeed ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 8),
                Text(
                  '温度与喂食关系',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTempRange('< 18°C', '禁止喂食', Colors.red),
            _buildTempRange('18-22°C', '谨慎喂食', Colors.orange),
            _buildTempRange('22-25°C', '可喂食(减量)', Colors.yellow[700]!),
            _buildTempRange('25-32°C', '正常喂食', Colors.green),
            _buildTempRange('> 35°C', '减少喂食', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildTempRange(String range, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(range, style: const TextStyle(fontSize: 13)),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(status, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }

  // 获取天气图标数据
  IconData _getWeatherIconData(String iconName) {
    switch (iconName) {
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'cloud':
        return Icons.cloud;
      case 'grain':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'foggy':
        return Icons.foggy;
      default:
        return Icons.wb_cloudy;
    }
  }

  // 获取天气图标颜色
  Color _getWeatherIconColor(String iconName) {
    switch (iconName) {
      case 'wb_sunny':
        return Colors.orange;
      case 'cloud':
        return Colors.grey;
      case 'grain':
        return Colors.blue;
      case 'thunderstorm':
        return Colors.deepPurple;
      case 'ac_unit':
        return Colors.lightBlue;
      case 'foggy':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  // 兼容旧的图标名称
  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return 'wb_sunny';
      case 'cloudy':
        return 'cloud';
      case 'rain':
      case 'rainy':
        return 'grain';
      case 'clouds':
        return 'cloud';
      default:
        return 'wb_cloudy';
    }
  }
}
