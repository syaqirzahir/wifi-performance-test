class Iperf3Server {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  Iperf3Server({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Iperf3Server.fromMap(Map<String, dynamic> map) {
    return Iperf3Server(
      id: map['id'] as int,
      name: map['name'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }
}
