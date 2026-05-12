import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/load_balancer_api.dart';
import '../domain/load_balancer_statistics.dart';
import '../domain/request_log_item.dart';
import 'session_exporter.dart';

class LoadBalancerController extends ChangeNotifier {
  LoadBalancerController({
    LoadBalancerApi? api,
    SessionExporterWeb? exporter,
  })  : _api = api ?? LoadBalancerApi(),
        _exporter = exporter ?? const SessionExporterWeb();

  static const historyLimit = 100;
  static const intervals = [
    Duration(milliseconds: 500),
    Duration(seconds: 1),
    Duration(seconds: 2),
  ];
  static const _baseUrlKey = 'load_balancer_base_url';

  final LoadBalancerApi _api;
  final SessionExporterWeb _exporter;

  Timer? _timer;
  bool _disposed = false;
  bool _isLoading = false;
  bool _isLive = false;
  int _nextIndex = 1;
  int _totalRequests = 0;
  int _successfulRequests = 0;
  int _latencyTotalMs = 0;
  Duration _pollingInterval = const Duration(seconds: 1);
  String _baseUrl = 'http://194.87.145.115';
  String? _baseUrlError;
  final List<RequestLogItem> _history = [];
  final Map<String, int> _serverHits = {};

  bool get isLoading => _isLoading;
  bool get isLive => _isLive;
  Duration get pollingInterval => _pollingInterval;
  String get baseUrl => _baseUrl;
  String? get baseUrlError => _baseUrlError;
  List<RequestLogItem> get history => List.unmodifiable(_history);
  RequestLogItem? get latest => _history.isEmpty ? null : _history.first;
  LoadBalancerStatistics get statistics => LoadBalancerStatistics.fromCounters(
        total: _totalRequests,
        success: _successfulRequests,
        failure: _totalRequests - _successfulRequests,
        latencyTotalMs: _latencyTotalMs,
        serverHits: _serverHits,
      );

  Future<void> loadSavedBaseUrl() async {
    final preferences = await SharedPreferences.getInstance();
    final savedValue = preferences.getString(_baseUrlKey);
    if (savedValue != null && savedValue.trim().isNotEmpty) {
      _baseUrl = savedValue;
      _safeNotify();
    }
  }

  Future<void> updateBaseUrl(String value) async {
    final normalized = _normalizeBaseUrl(value);
    if (normalized == null) {
      _baseUrlError = 'Enter a valid URL or host.';
      _safeNotify();
      return;
    }

    _baseUrl = normalized;
    _baseUrlError = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_baseUrlKey, normalized);
    _safeNotify();
  }

  void setPollingInterval(Duration interval) {
    if (_pollingInterval == interval) {
      return;
    }

    _pollingInterval = interval;
    if (_isLive) {
      stopLiveMode();
      startLiveMode();
    } else {
      _safeNotify();
    }
  }

  Future<void> sendRequest() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _safeNotify();

    final result = await _api.fetchRoot(_baseUrl);
    if (_disposed) {
      return;
    }

    final response = result.response;
    final item = RequestLogItem(
      index: _nextIndex++,
      timestamp: response?.receivedAt ?? DateTime.now(),
      serverId: response?.serverId,
      note: response?.note,
      statusCode: result.statusCode,
      latencyMs: result.latencyMs,
      isSuccess: result.isSuccess,
      errorMessage: result.errorMessage,
    );

    _history.insert(0, item);
    _recordStatistics(item);
    if (_history.length > historyLimit) {
      _history.removeRange(historyLimit, _history.length);
    }

    _isLoading = false;
    _safeNotify();
  }

  void startLiveMode() {
    if (_isLive) {
      return;
    }

    _isLive = true;
    _timer?.cancel();
    _timer = Timer.periodic(_pollingInterval, (_) {
      unawaited(sendRequest());
    });
    unawaited(sendRequest());
    _safeNotify();
  }

  void stopLiveMode() {
    _timer?.cancel();
    _timer = null;
    _isLive = false;
    _safeNotify();
  }

  void clearHistory() {
    _history.clear();
    _nextIndex = 1;
    _totalRequests = 0;
    _successfulRequests = 0;
    _latencyTotalMs = 0;
    _serverHits.clear();
    _safeNotify();
  }

  void exportJson() {
    _exporter.downloadText(
      filename: _sessionFilename('json'),
      mimeType: 'application/json',
      content: const JsonEncoder.withIndent('  ').convert(_sessionData()),
    );
  }

  void exportCsv() {
    final rows = <List<String>>[
      [
        'index',
        'timestamp',
        'server_id',
        'note',
        'status_code',
        'latency_ms',
        'is_success',
        'error_message',
      ],
      ..._history.reversed.map(
        (item) => [
          item.index.toString(),
          item.timestamp.toIso8601String(),
          item.serverId ?? '',
          item.note ?? '',
          item.statusCode?.toString() ?? '',
          item.latencyMs.toString(),
          item.isSuccess.toString(),
          item.errorMessage ?? '',
        ],
      ),
      <String>[],
      ['metric', 'value'],
      ['total', statistics.total.toString()],
      ['success', statistics.success.toString()],
      ['failure', statistics.failure.toString()],
      ['average_latency_ms', statistics.averageLatencyMs.toString()],
      ...statistics.serverHits.entries.map(
        (entry) => ['server_${entry.key}_hits', entry.value.toString()],
      ),
    ];

    _exporter.downloadText(
      filename: _sessionFilename('csv'),
      mimeType: 'text/csv',
      content: rows.map(_csvRow).join('\n'),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _api.close();
    super.dispose();
  }

  Map<String, Object?> _sessionData() {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'base_url': _baseUrl,
      'statistics': statistics.toJson(),
      'history_limit': historyLimit,
      'history_count': _history.length,
      'history': _history.reversed.map((item) => item.toJson()).toList(),
    };
  }

  void _recordStatistics(RequestLogItem item) {
    _totalRequests += 1;
    _latencyTotalMs += item.latencyMs;

    final serverId = item.serverId;
    if (item.isSuccess) {
      _successfulRequests += 1;
      if (serverId != null && serverId.isNotEmpty) {
        _serverHits[serverId] = (_serverHits[serverId] ?? 0) + 1;
      }
    }
  }

  String _sessionFilename(String extension) {
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    return 'load-balancer-session-$timestamp.$extension';
  }

  String _csvRow(List<String> values) {
    return values.map((value) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }).join(',');
  }

  String? _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final withScheme = trimmed.contains('://') ? trimmed : 'http://$trimmed';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || uri.host.isEmpty) {
      return null;
    }

    return uri.replace(path: '', query: null, fragment: null).toString();
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
