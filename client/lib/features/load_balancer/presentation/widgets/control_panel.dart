import 'package:flutter/material.dart';

import '../load_balancer_controller.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({
    required this.controller,
    required this.baseUrlController,
    super.key,
  });

  final LoadBalancerController controller;
  final TextEditingController baseUrlController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: controller.isLoading
                  ? null
                  : () async {
                      await controller.updateBaseUrl(baseUrlController.text);
                      if (controller.baseUrlError == null) {
                        await controller.sendRequest();
                      }
                    },
              icon: controller.isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: const Text('Send Request'),
            ),
            FilledButton.tonalIcon(
              onPressed: controller.isLive
                  ? null
                  : () async {
                      await controller.updateBaseUrl(baseUrlController.text);
                      if (controller.baseUrlError == null) {
                        controller.startLiveMode();
                      }
                    },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Live Mode'),
            ),
            OutlinedButton.icon(
              onPressed: controller.isLive ? controller.stopLiveMode : null,
              icon: const Icon(Icons.stop),
              label: const Text('Stop Live Mode'),
            ),
            SegmentedButton<Duration>(
              segments: const [
                ButtonSegment(
                  value: Duration(milliseconds: 500),
                  label: Text('500 ms'),
                ),
                ButtonSegment(
                  value: Duration(seconds: 1),
                  label: Text('1 sec'),
                ),
                ButtonSegment(
                  value: Duration(seconds: 2),
                  label: Text('2 sec'),
                ),
              ],
              selected: {controller.pollingInterval},
              onSelectionChanged: (selection) {
                controller.setPollingInterval(selection.first);
              },
            ),
            OutlinedButton.icon(
              onPressed: controller.history.isEmpty
                  ? null
                  : controller.exportJson,
              icon: const Icon(Icons.data_object),
              label: const Text('JSON'),
            ),
            OutlinedButton.icon(
              onPressed: controller.history.isEmpty
                  ? null
                  : controller.exportCsv,
              icon: const Icon(Icons.table_view),
              label: const Text('CSV'),
            ),
            IconButton.outlined(
              tooltip: 'Clear history',
              onPressed: controller.history.isEmpty
                  ? null
                  : controller.clearHistory,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
