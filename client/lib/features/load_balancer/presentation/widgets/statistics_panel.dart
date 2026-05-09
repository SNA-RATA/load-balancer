import 'package:flutter/material.dart';

import '../../domain/load_balancer_statistics.dart';

class StatisticsPanel extends StatelessWidget {
  const StatisticsPanel({required this.statistics, super.key});

  final LoadBalancerStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.query_stats, color: Color(0xFF007C89)),
                const SizedBox(width: 10),
                Text('Session statistics',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricTile(label: 'Total', value: '${statistics.total}'),
                _MetricTile(label: 'Success', value: '${statistics.success}'),
                _MetricTile(label: 'Failure', value: '${statistics.failure}'),
                _MetricTile(
                  label: 'Avg latency',
                  value: '${statistics.averageLatencyMs} ms',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Server hit counter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            if (statistics.serverHits.isEmpty)
              const Text(
                'Successful responses will appear here.',
                style: TextStyle(color: Color(0xFF68717A)),
              )
            else
              ...statistics.serverHits.entries.map(
                (entry) => _ServerBar(
                  serverId: entry.key,
                  count: entry.value,
                  percentage: statistics.percentageFor(entry.key),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F8F8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD8E8EA)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF68717A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServerBar extends StatelessWidget {
  const _ServerBar({
    required this.serverId,
    required this.count,
    required this.percentage,
  });

  final String serverId;
  final int count;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  serverId,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text('$count (${(percentage * 100).round()}%)'),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: percentage.clamp(0, 1),
              backgroundColor: const Color(0xFFE6E9EC),
              color: const Color(0xFF007C89),
            ),
          ),
        ],
      ),
    );
  }
}
