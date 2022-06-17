class Album {
  final String sensor;
  final double value;
  final double timestamp;

  const Album({
    required this.sensor,
    required this.value,
    required this.timestamp,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      sensor: json['sensor'],
      value: json['value'],
      timestamp: json['timestamp'],
    );
  }
}
