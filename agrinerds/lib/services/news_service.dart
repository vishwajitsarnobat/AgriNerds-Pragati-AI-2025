import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class NewsItem {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final DateTime publishedAt;
  final String source;

  NewsItem({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.publishedAt,
    required this.source,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      publishedAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toIso8601String()),
      source: json['source']['name'] ?? '',
    );
  }
}

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = ApiConfig.newsApiKey;

  Future<List<NewsItem>> getAgricultureNews() async {
    try {
      // Trusted Indian news domains
      const domains = 'thehindu.com,indianexpress.com,timesofindia.indiatimes.com,business-standard.com,livemint.com,financialexpress.com,krishijagran.com,agriculturetoday.in,timesofagriculture.in,downtoearth.org.in';

      // Get current date and date 3 days ago
      final now = DateTime.now();
      final threeDaysAgo = now.subtract(const Duration(days: 3));
      final fromDate = threeDaysAgo.toIso8601String().split('T')[0];
      final toDate = now.toIso8601String().split('T')[0];

      // Core terms and government schemes
      final query = Uri.encodeQueryComponent(
        '(farmers OR agriculture OR farming OR crops OR kisan OR krishi OR '
        '"PM Kisan" OR "PM-KISAN" OR "PMFBY" OR "Pradhan Mantri Fasal Bima Yojana" OR '
        '"Kisan Credit Card" OR "KCC" OR "Soil Health Card" OR "e-NAM" OR '
        '"National Agriculture Market" OR "MSP" OR "Minimum Support Price" OR '
        '"Kisan Samman Nidhi" OR "Kisan MaanDhan" OR "Kisan Rail" OR "Kisan Udan") '
        'AND (India OR Indian)'
      );
      
      final url = '$_baseUrl/everything?'
          'q=$query&'
          'domains=$domains&'
          'language=en&'
          'sortBy=relevancy&'
          'pageSize=20&'
          'from=$fromDate&'
          'to=$toDate&'
          'apiKey=$_apiKey';
      
      debugPrint('News API URL: $url');
      
      final response = await http.get(Uri.parse(url));

      debugPrint('News API Response Status: ${response.statusCode}');
      debugPrint('News API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['articles'] == null) {
          debugPrint('No articles found in response');
          return [];
        }
        final articles = data['articles'] as List;
        if (articles.isEmpty) {
          debugPrint('Empty articles list received');
          return [];
        }
        return articles.map((article) => NewsItem.fromJson(article)).toList();
      } else {
        debugPrint('News API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      debugPrint('News API Exception: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }
}
