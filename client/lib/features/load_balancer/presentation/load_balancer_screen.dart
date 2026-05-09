import 'dart:async';

import 'package:flutter/material.dart';

import 'load_balancer_controller.dart';
import 'widgets/control_panel.dart';
import 'widgets/history_table.dart';
import 'widgets/latest_response_card.dart';
import 'widgets/statistics_panel.dart';

class LoadBalancerScreen extends StatefulWidget {
  const LoadBalancerScreen({super.key});

  @override
  State<LoadBalancerScreen> createState() => _LoadBalancerScreenState();
}

class _LoadBalancerScreenState extends State<LoadBalancerScreen> {
  late final LoadBalancerController _controller;
  late final TextEditingController _baseUrlController;

  @override
  void initState() {
    super.initState();
    _controller = LoadBalancerController();
    _baseUrlController = TextEditingController(text: _controller.baseUrl);
    unawaited(_loadSavedBaseUrl());
  }

  Future<void> _loadSavedBaseUrl() async {
    await _controller.loadSavedBaseUrl();
    if (mounted) {
      _baseUrlController.text = _controller.baseUrl;
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Load Balancer Dashboard'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: _LiveStatusBadge(isLive: _controller.isLive),
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ControlPanel(
                          controller: _controller,
                          baseUrlController: _baseUrlController,
                        ),
                        const SizedBox(height: 16),
                        if (isWide)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: LatestResponseCard(
                                    item: _controller.latest,
                                    isLoading: _controller.isLoading,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 7,
                                  child: StatisticsPanel(
                                    statistics: _controller.statistics,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          LatestResponseCard(
                            item: _controller.latest,
                            isLoading: _controller.isLoading,
                          ),
                          const SizedBox(height: 16),
                          StatisticsPanel(statistics: _controller.statistics),
                        ],
                        const SizedBox(height: 16),
                        HistoryTable(items: _controller.history),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _LiveStatusBadge extends StatelessWidget {
  const _LiveStatusBadge({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final color = isLive ? const Color(0xFF0B8F62) : const Color(0xFF68717A);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLive ? Icons.play_circle_outline : Icons.pause_circle_outline,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              isLive ? 'Live' : 'Idle',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
