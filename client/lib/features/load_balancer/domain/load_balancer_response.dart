class LoadBalancerResponse {
  const LoadBalancerResponse({
    required this.serverId,
    required this.note,
    required this.statusCode,
    required this.latencyMs,
    required this.receivedAt,
  });

  final String serverId;
  final String note;
  final int statusCode;
  final int latencyMs;
  final DateTime receivedAt;

  Map<String, Object?> toJson() {
    return {
      'server_id': serverId,
      'note': note,
      'status_code': statusCode,
      'latency_ms': latencyMs,
      'received_at': receivedAt.toIso8601String(),
    };
  }
}
