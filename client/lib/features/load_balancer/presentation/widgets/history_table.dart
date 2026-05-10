import 'package:flutter/material.dart';

import '../../domain/request_log_item.dart';

class HistoryTable extends StatelessWidget {
  const HistoryTable({required this.items, super.key});

  final List<RequestLogItem> items;

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
                const Icon(Icons.history, color: Color(0xFF007C89)),
                const SizedBox(width: 10),
                Text('Request history',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Text(
                  '${items.length}/100',
                  style: const TextStyle(color: Color(0xFF68717A)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'History is empty.',
                  style: TextStyle(color: Color(0xFF68717A)),
                ),
              )
            else
              Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF2F5F7),
                    ),
                    columns: const [
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('Time')),
                      DataColumn(label: Text('Server')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Latency')),
                      DataColumn(label: Text('Note / Error')),
                    ],
                    rows: items.map(_rowFor).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DataRow _rowFor(RequestLogItem item) {
    final color =
        item.isSuccess ? const Color(0xFF0B8F62) : const Color(0xFFB42318);
    return DataRow(
      cells: [
        DataCell(Text('${item.index}')),
        DataCell(Text(_formatTime(item.timestamp))),
        DataCell(Text(item.serverId ?? '-')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.isSuccess ? Icons.check_circle : Icons.error,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(item.statusLabel),
            ],
          ),
        ),
        DataCell(Text('${item.latencyMs} ms')),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Text(
              item.errorMessage ?? item.note ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }
}
