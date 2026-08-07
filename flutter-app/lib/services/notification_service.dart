import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:read_the_label/repositories/api_client.dart';
import 'package:read_the_label/services/auth_service.dart';

class NotificationService {
  final ApiClient _apiClient;
  final AuthService _authService;
  final StreamController<void> _mealLoggedController = StreamController<void>.broadcast();

  Stream<void> get onMealLogged => _mealLoggedController.stream;

  http.Client? _client;
  bool _isConnecting = false;
  Timer? _reconnectTimer;

  NotificationService(this._apiClient, this._authService) {
    _authService.authStateChanges().listen((user) {
      if (user != null) {
        _connect(user.uid);
      } else {
        _disconnect();
      }
    });
  }

  void _connect(String userId) async {
    if (_isConnecting) return;
    _disconnect();
    _isConnecting = true;

    final baseUrl = _apiClient.baseUrl;
    final url = Uri.parse('$baseUrl/notifications/stream?userId=$userId');
    debugPrint('NotificationService: Connecting to SSE stream at $url');

    _client = http.Client();
    final request = http.Request('GET', url);
    final headers = await _apiClient.getRequestHeaders(includeContentType: false);
    request.headers.addAll(headers);
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Cache-Control'] = 'no-cache';

    try {
      final response = await _client!.send(request);
      _isConnecting = false;

      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (line.trim().isEmpty) return;
          debugPrint('NotificationService SSE line: $line');
          if (line.contains('meal_logged')) {
            debugPrint('NotificationService: Meal logged notification received! Broadcasting...');
            _mealLoggedController.add(null);
          }
        },
        onError: (e) {
          debugPrint('NotificationService stream error: $e');
          _scheduleReconnect(userId);
        },
        onDone: () {
          debugPrint('NotificationService stream completed.');
          _scheduleReconnect(userId);
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('NotificationService connection error: $e');
      _isConnecting = false;
      _scheduleReconnect(userId);
    }
  }

  void _scheduleReconnect(String userId) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      debugPrint('NotificationService: Reconnecting...');
      _connect(userId);
    });
  }

  void _disconnect() {
    _reconnectTimer?.cancel();
    _client?.close();
    _client = null;
    _isConnecting = false;
  }

  void dispose() {
    _disconnect();
    _mealLoggedController.close();
  }
}
