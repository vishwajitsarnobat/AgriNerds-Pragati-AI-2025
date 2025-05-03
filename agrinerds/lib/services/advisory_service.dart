import '../models/weather_data.dart';

class AdvisoryService {
  List<AdvisoryItem> getFarmAdvisory(WeatherData weatherData) {
    final List<AdvisoryItem> advisories = [];

    // Temperature-based advisories with more specific ranges
    if (weatherData.temperature < 5) {
      advisories.add(AdvisoryItem(
        icon: '❄️',
        title: 'Severe Cold Alert',
        description: 'Protect all crops with frost covers. Delay all planting activities. Consider using row covers for existing plants.',
        priority: AdvisoryPriority.high,
      ));
    } else if (weatherData.temperature < 10) {
      advisories.add(AdvisoryItem(
        icon: '❄️',
        title: 'Cold Weather Alert',
        description: 'Protect sensitive crops with frost covers. Delay planting of warm-season crops. Consider using cold frames.',
        priority: AdvisoryPriority.medium,
      ));
    } else if (weatherData.temperature > 35) {
      advisories.add(AdvisoryItem(
        icon: '🌡️',
        title: 'Extreme Heat Warning',
        description: 'Increase irrigation frequency significantly. Provide shade for all crops. Consider using shade cloths. Harvest in early morning.',
        priority: AdvisoryPriority.high,
      ));
    } else if (weatherData.temperature > 30) {
      advisories.add(AdvisoryItem(
        icon: '🌡️',
        title: 'Heat Stress Warning',
        description: 'Increase irrigation frequency. Consider shading for sensitive plants. Water in early morning or late evening.',
        priority: AdvisoryPriority.medium,
      ));
    }

    // Weather condition-based advisories
    final weatherDescription = weatherData.getWeatherDescription().toLowerCase();
    if (weatherDescription.contains('rain')) {
      advisories.add(AdvisoryItem(
        icon: '💧',
        title: 'Rainfall Advisory',
        description: 'Reduce irrigation. Check drainage systems. Monitor for waterlogging. Delay fertilizer application.',
        priority: AdvisoryPriority.medium,
      ));
    } else if (weatherDescription.contains('clear')) {
      advisories.add(AdvisoryItem(
        icon: '☀️',
        title: 'Dry Weather Advisory',
        description: 'Increase irrigation frequency. Monitor soil moisture levels. Consider mulching to retain moisture.',
        priority: AdvisoryPriority.medium,
      ));
    } else if (weatherDescription.contains('fog')) {
      advisories.add(AdvisoryItem(
        icon: '🌫️',
        title: 'Fog Advisory',
        description: 'Monitor for fungal diseases. Ensure proper ventilation. Delay spraying operations.',
        priority: AdvisoryPriority.low,
      ));
    }

    // Wind-based advisories with specific thresholds
    if (weatherData.windSpeed > 10) {
      advisories.add(AdvisoryItem(
        icon: '💨',
        title: 'Strong Wind Warning',
        description: 'Secure all structures and equipment. Delay all spraying operations. Protect young plants with windbreaks.',
        priority: AdvisoryPriority.high,
      ));
    } else if (weatherData.windSpeed > 5) {
      advisories.add(AdvisoryItem(
        icon: '💨',
        title: 'Wind Advisory',
        description: 'Secure greenhouses and temporary structures. Delay spraying operations. Consider wind protection for sensitive crops.',
        priority: AdvisoryPriority.medium,
      ));
    }

    // Humidity-based advisories with specific ranges
    if (weatherData.humidity > 85) {
      advisories.add(AdvisoryItem(
        icon: '🌫️',
        title: 'High Humidity Alert',
        description: 'High risk of fungal diseases. Ensure maximum ventilation. Consider fungicide application. Monitor for pest outbreaks.',
        priority: AdvisoryPriority.high,
      ));
    } else if (weatherData.humidity > 70) {
      advisories.add(AdvisoryItem(
        icon: '🌫️',
        title: 'Moderate Humidity Alert',
        description: 'Monitor for fungal diseases. Ensure proper ventilation in greenhouses. Consider preventive measures.',
        priority: AdvisoryPriority.medium,
      ));
    } else if (weatherData.humidity < 30) {
      advisories.add(AdvisoryItem(
        icon: '🏜️',
        title: 'Low Humidity Alert',
        description: 'Increase irrigation frequency. Consider mulching to retain soil moisture. Monitor for water stress.',
        priority: AdvisoryPriority.medium,
      ));
    }

    // Seasonal advisories with more specific recommendations
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) {
      advisories.add(AdvisoryItem(
        icon: '🌱',
        title: 'Spring Planting Guide',
        description: 'Start preparing soil for spring crops. Begin planting cool-season vegetables. Monitor for late frosts.',
        priority: AdvisoryPriority.low,
      ));
    } else if (month >= 6 && month <= 8) {
      advisories.add(AdvisoryItem(
        icon: '🌞',
        title: 'Summer Care Guide',
        description: 'Monitor for pests and diseases. Maintain regular watering schedule. Consider shade for sensitive plants.',
        priority: AdvisoryPriority.low,
      ));
    } else if (month >= 9 && month <= 11) {
      advisories.add(AdvisoryItem(
        icon: '🍂',
        title: 'Fall Harvest Guide',
        description: 'Prepare for harvest season. Start planning winter cover crops. Begin fall planting of cool-season crops.',
        priority: AdvisoryPriority.low,
      ));
    } else {
      advisories.add(AdvisoryItem(
        icon: '❄️',
        title: 'Winter Preparation Guide',
        description: 'Protect perennial plants. Plan for next season\'s crops. Maintain soil health with cover crops.',
        priority: AdvisoryPriority.low,
      ));
    }

    // Sort advisories by priority
    advisories.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return advisories;
  }
}

enum AdvisoryPriority {
  high,
  medium,
  low,
}

class AdvisoryItem {
  final String icon;
  final String title;
  final String description;
  final AdvisoryPriority priority;

  AdvisoryItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.priority,
  });
} 