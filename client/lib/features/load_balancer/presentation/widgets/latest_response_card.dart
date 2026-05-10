import 'package:flutter/material.dart';

import '../../domain/request_log_item.dart';

class LatestResponseCard extends StatelessWidget {
  const LatestResponseCard({
    required this.item,
    required this.isLoading,
    super.key,
  });

  final RequestLogItem? item;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final current = item;
    final isError = current != null && !current.isSuccess;
    final color = isError ? const Color(0xFFB42318) : const Color(0xFF0B8F62);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.dns_outlined,
                  color: current == null ? const Color(0xFF68717A) : color,
                ),
                const SizedBox(width: 10),
                Text(
                  'Last response',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (isLoading) ...[
                  const Spacer(),
                  const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            if (current == null)
              const _EmptyState()
            else ...[
              _FactLine(label: 'Server', value: current.serverId ?? '-'),
              _FactLine(label: 'Note', value: current.note ?? '-'),
              _FactLine(label: 'Status', value: current.statusLabel),
              _FactLine(label: 'Latency', value: '${current.latencyMs} ms'),
              _FactLine(label: 'Time', value: _formatTime(current.timestamp)),
              if (current.errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  current.errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFFB42318),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }
}

class _FactLine extends StatelessWidget {
  const _FactLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Color(0xFF68717A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: Text(
        'No requests yet.',
        style: TextStyle(color: Color(0xFF68717A)),
      ),
    );
  }
}
