class InsectResult {
  final String className;   // 벌레 영어 이름
  final String insectType;  // 익충 / 해충
  final double confidence;  // 모델 신뢰도
  final double latitude;    // 위치
  final double longitude;
  final DateTime timestamp;

  InsectResult({
    required this.className,
    required this.insectType,
    required this.confidence,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'insectType': insectType,
      'confidence': confidence,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory InsectResult.fromMap(Map<String, dynamic> map) {
    return InsectResult(
      className: map['className'] ?? '',
      insectType: map['insectType'] ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
