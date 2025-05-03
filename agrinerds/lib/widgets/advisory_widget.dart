import 'package:flutter/material.dart';
import '../services/advisory_service.dart';
import '../models/weather_data.dart';
import '../constants/app_constants.dart';

class AdvisoryWidget extends StatefulWidget {
  final WeatherData? weatherData;
  static final AdvisoryService _advisoryService = AdvisoryService();

  const AdvisoryWidget({
    super.key,
    this.weatherData,
  });

  @override
  State<AdvisoryWidget> createState() => _AdvisoryWidgetState();
}

class _AdvisoryWidgetState extends State<AdvisoryWidget> {
  late List<AdvisoryItem> _advisories;

  @override
  void initState() {
    super.initState();
    _updateAdvisories();
  }

  @override
  void didUpdateWidget(AdvisoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weatherData != widget.weatherData) {
      _updateAdvisories();
    }
  }

  void _updateAdvisories() {
    setState(() {
      _advisories = widget.weatherData != null
          ? AdvisoryWidget._advisoryService.getFarmAdvisory(widget.weatherData!)
          : [];
    });
  }

  Color _getPriorityColor(AdvisoryPriority priority) {
    switch (priority) {
      case AdvisoryPriority.high:
        return Colors.red;
      case AdvisoryPriority.medium:
        return Colors.orange;
      case AdvisoryPriority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Farming Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _updateAdvisories,
                      tooltip: 'Update advisories',
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Advisory Priority Guide'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildPriorityLegend(AdvisoryPriority.high),
                                _buildPriorityLegend(AdvisoryPriority.medium),
                                _buildPriorityLegend(AdvisoryPriority.low),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      tooltip: 'Priority Guide',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._advisories.map((advisory) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAdvisoryItem(advisory),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityLegend(AdvisoryPriority priority) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getPriorityColor(priority),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            priority.toString().split('.').last.toUpperCase(),
            style: TextStyle(
              color: _getPriorityColor(priority),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryItem(AdvisoryItem advisory) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: _getPriorityColor(advisory.priority),
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              advisory.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    advisory.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    advisory.description,
                    style: const TextStyle(
                      color: Colors.grey,
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
} 