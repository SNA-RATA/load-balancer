import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/load_balancer_response.dart';
import 'load_balancer_dto.dart';

class LoadBalancerApi {
  LoadBalancerApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<LoadBalancerApiResult> fetchRoot(String baseUrl) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client
          .get(_rootUri(baseUrl))
          .timeout(const Duration(seconds: 10));
      stopwatch.stop();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return LoadBalancerApiResult.failure(
          statusCode: response.statusCode,
          latencyMs: stopwatch.elapsedMilliseconds,
          errorMessage: 'Nginx returned HTTP ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return LoadBalancerApiResult.failure(
          statusCode: response.statusCode,
          latencyMs: stopwatch.elapsedMilliseconds,
          errorMessage: 'Response was not a JSON object.',
        );
      }

      final dto = LoadBalancerDto.fromJson(decoded);
      if (dto.serverId.isEmpty) {
        return LoadBalancerApiResult.failure(
          statusCode: response.statusCode,
          latencyMs: stopwatch.elapsedMilliseconds,
          errorMessage: 'Response did not include server_id.',
        );
      }

      return LoadBalancerApiResult.success(
        LoadBalancerResponse(
          serverId: dto.serverId,
          note: dto.note,
          statusCode: response.statusCode,
          latencyMs: stopwatch.elapsedMilliseconds,
          receivedAt: DateTime.now(),
        ),
      );
    } on TimeoutException {
      stopwatch.stop();
      return LoadBalancerApiResult.failure(
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: 'Request timed out after 10 seconds.',
      );
    } on FormatException catch (error) {
      stopwatch.stop();
      return LoadBalancerApiResult.failure(
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: 'Invalid JSON response: ${error.message}',
      );
    } on Object catch (error) {
      stopwatch.stop();
      return LoadBalancerApiResult.failure(
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: error.toString(),
      );
    }
  }

  void close() {
    _client.close();
  }

  Uri _rootUri(String baseUrl) {
    final trimmed = baseUrl.trim();
    final withScheme = trimmed.contains('://') ? trimmed : 'http://$trimmed';
    final uri = Uri.parse(withScheme);
    return uri.replace(path: '/', query: null, fragment: null);
  }
}

class LoadBalancerApiResult {
  const LoadBalancerApiResult._({
    required this.response,
    required this.statusCode,
    required this.latencyMs,
    required this.errorMessage,
  });

  factory LoadBalancerApiResult.success(LoadBalancerResponse response) {
    return LoadBalancerApiResult._(
      response: response,
      statusCode: response.statusCode,
      latencyMs: response.latencyMs,
      errorMessage: null,
    );
  }

  factory LoadBalancerApiResult.failure({
    required int latencyMs,
    required String errorMessage,
    int? statusCode,
  }) {
    return LoadBalancerApiResult._(
      response: null,
      statusCode: statusCode,
      latencyMs: latencyMs,
      errorMessage: errorMessage,
    );
  }

  final LoadBalancerResponse? response;
  final int? statusCode;
  final int latencyMs;
  final String? errorMessage;

  bool get isSuccess => response != null;
}
