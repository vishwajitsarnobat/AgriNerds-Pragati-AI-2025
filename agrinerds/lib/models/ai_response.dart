class AIResponse {
  final String recommendation;
  final Map<String, dynamic> analysis;
  final double confidence;
  final List<String> supportingFactors;
  final DateTime timestamp;

  AIResponse({
    required this.recommendation,
    required this.analysis,
    required this.confidence,
    required this.supportingFactors,
    required this.timestamp,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      recommendation: json['recommendation'] as String,
      analysis: json['analysis'] as Map<String, dynamic>,
      confidence: (json['confidence'] as num).toDouble(),
      supportingFactors: List<String>.from(json['supporting_factors']),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendation': recommendation,
      'analysis': analysis,
      'confidence': confidence,
      'supporting_factors': supportingFactors,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 