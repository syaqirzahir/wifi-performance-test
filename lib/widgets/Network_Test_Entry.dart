class NetworkTestEntry {
  final String date;
  final String duration;
  final String throughput;
  final String packetLoss;
  final String jitter;
  final String latency;

  NetworkTestEntry({
    required this.date,
    required this.duration,
    required this.throughput,
    required this.packetLoss,
    required this.jitter,
    required this.latency,
  });
}
