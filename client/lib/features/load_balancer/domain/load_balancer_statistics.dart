import 'request_log_item.dart';

class LoadBalancerStatistics {
  const LoadBalancerStatistics({
    required this.total,
    required this.success,
    required this.failure,
    required this.averageLatencyMs,
    required this.serverHits,
  });

  factory LoadBalancerStatistics.fromHistory(List<RequestLogItem> history) {
    final hits = <String, int>{};
    var latencyTotal = 0;
    var success = 0;

    for (final item in history) {
      latencyTotal += item.latencyMs;
      final serverId = item.serverId;
      if (item.isSuccess) {
        success += 1;
        if (serverId != null && serverId.isNotEmpty) {
          hits[serverId] = (hits[serverId] ?? 0) + 1;
        }
      }
    }

    return LoadBalancerStatistics.fromCounters(
      total: history.length,
      success: success,
      failure: history.length - success,
      latencyTotalMs: latencyTotal,
      serverHits: hits,
    );
  }

  factory LoadBalancerStatistics.fromCounters({
    required int total,
    required int success,
    required int failure,
    required int latencyTotalMs,
    required Map<String, int> serverHits,
  }) {
    final orderedHits = Map.fromEntries(
      serverHits.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    return LoadBalancerStatistics(
      total: total,
      success: success,
      failure: failure,
      averageLatencyMs: total == 0 ? 0 : (latencyTotalMs / total).round(),
      serverHits: orderedHits,
    );
  }

  final int total;
  final int success;
  final int failure;
  final int averageLatencyMs;
  final Map<String, int> serverHits;

  double percentageFor(String serverId) {
    if (success == 0) {
      return 0;
    }
    return (serverHits[serverId] ?? 0) / success;
  }

  Map<String, Object?> toJson() {
    return {
      'total': total,
      'success': success,
      'failure': failure,
      'average_latency_ms': averageLatencyMs,
      'server_hits': serverHits,
    };
  }
}
