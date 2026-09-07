class SavedReading {
  final String id;
  final String label;
  final double x;
  final double y;
  final DateTime timestamp;

  SavedReading({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'x': x,
    'y': y,
    'timestamp': timestamp.toIso8601String(),
  };

  factory SavedReading.fromJson(Map<String, dynamic> json) => SavedReading(
    id: json['id'] as String,
    label: json['label'] as String,
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
