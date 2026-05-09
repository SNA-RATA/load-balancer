class RequestLogItem {
  const RequestLogItem({
    required this.index,
    required this.timestamp,
    required this.serverId,
    required this.note,
    required this.statusCode,
    required this.latencyMs,
    required this.isSuccess,
    required this.errorMessage,
  });

  final int index;
  final DateTime timestamp;
  final String? serverId;
  final String? note;
  final int? statusCode;
  final int latencyMs;
  final bool isSuccess;
  final String? errorMessage;

  String get statusLabel {
    final code = statusCode;
    if (code == null) {
      return isSuccess ? 'OK' : 'Failed';
    }
    if (code >= 200 && code < 300) {
      return '$code OK';
    }
    return '$code Error';
  }

  Map<String, Object?> toJson() {
    return {
      'index': index,
      'timestamp': timestamp.toIso8601String(),
      'server_id': serverId,
      'note': note,
      'status_code': statusCode,
      'latency_ms': latencyMs,
      'is_success': isSuccess,
      'error_message': errorMessage,
    };
  }
}
