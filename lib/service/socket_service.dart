import 'package:flutter/foundation.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

const String tokenKey = 'token';

/// Socket.IO Service for Laravel Reverb WebSocket connections
/// Handles real-time communication with the backend
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  // Callbacks for connection events
  Function()? onConnect;
  Function(dynamic)? onDisconnect;
  Function(dynamic)? onError;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  /// Initialize and connect to Laravel Reverb
  Future<void> connect() async {
    if (_isConnected || _isConnecting) {
      if (kDebugMode) {
        print('🔌 [SocketService] Already connected or connecting');
      }
      return;
    }

    _isConnecting = true;
    final baseUrl = _getBaseUrl();
    final token = getStringAsync(tokenKey);

    if (token.isEmpty) {
      if (kDebugMode) {
        print('❌ [SocketService] Cannot connect - No auth token found');
      }
      _isConnecting = false;
      return;
    }

    try {
      if (kDebugMode) {
        print('🔌 [SocketService] Connecting to Laravel Reverb at: $baseUrl');
      }

      _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling']) // Use websocket first, fallback to polling
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(_maxReconnectAttempts)
            .setReconnectionDelay(2000)
            .setReconnectionDelayMax(10000)
            .setTimeout(20000)
            .setAuth({'token': 'Bearer $token'})
            .setExtraHeaders({
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            })
            .build(),
      );

      _setupEventListeners();
      _isConnecting = false;

      if (kDebugMode) {
        print('✅ [SocketService] Socket instance created');
      }
    } catch (e) {
      _isConnecting = false;
      if (kDebugMode) {
        print('❌ [SocketService] Error creating socket: $e');
      }
    }
  }

  /// Setup socket event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection successful
    _socket!.onConnect((_) {
      _isConnected = true;
      _reconnectAttempts = 0;
      if (kDebugMode) {
        print('✅ [SocketService] Connected to Laravel Reverb');
        print('📡 [SocketService] Socket ID: ${_socket!.id}');
      }
      onConnect?.call();
    });

    // Connection error
    _socket!.onConnectError((error) {
      _isConnected = false;
      if (kDebugMode) {
        print('❌ [SocketService] Connection error: $error');
      }
      onError?.call(error);
    });

    // Disconnected
    _socket!.onDisconnect((reason) {
      _isConnected = false;
      if (kDebugMode) {
        print('🔌 [SocketService] Disconnected: $reason');
      }
      onDisconnect?.call(reason);
    });

    // Reconnection attempt
    _socket!.onReconnectAttempt((attempt) {
      _reconnectAttempts = attempt as int;
      if (kDebugMode) {
        print('🔄 [SocketService] Reconnection attempt: $attempt/$_maxReconnectAttempts');
      }
    });

    // Reconnection failed
    _socket!.onReconnectFailed((_) {
      _isConnected = false;
      if (kDebugMode) {
        print('❌ [SocketService] Reconnection failed after $_maxReconnectAttempts attempts');
      }
    });

    // Reconnected successfully
    _socket!.onReconnect((attempt) {
      _isConnected = true;
      _reconnectAttempts = 0;
      if (kDebugMode) {
        print('✅ [SocketService] Reconnected successfully after $attempt attempts');
      }
    });

    // General error handler
    _socket!.on('error', (error) {
      if (kDebugMode) {
        print('❌ [SocketService] Socket error: $error');
      }
      onError?.call(error);
    });

    // Connection timeout
    _socket!.on('connect_timeout', (_) {
      _isConnected = false;
      if (kDebugMode) {
        print('⏱️ [SocketService] Connection timeout');
      }
    });
  }

  /// Subscribe to a channel
  void subscribe(String channel) {
    if (!_isConnected || _socket == null) {
      if (kDebugMode) {
        print('⚠️ [SocketService] Cannot subscribe to $channel - Not connected');
      }
      return;
    }

    if (kDebugMode) {
      print('📢 [SocketService] Subscribing to channel: $channel');
    }

    _socket!.emit('subscribe', {'channel': channel});
  }

  /// Unsubscribe from a channel
  void unsubscribe(String channel) {
    if (_socket == null) return;

    if (kDebugMode) {
      print('📢 [SocketService] Unsubscribing from channel: $channel');
    }

    _socket!.emit('unsubscribe', {'channel': channel});
  }

  /// Listen to an event
  void on(String event, Function(dynamic) callback) {
    if (_socket == null) {
      if (kDebugMode) {
        print('⚠️ [SocketService] Cannot listen to $event - Socket not initialized');
      }
      return;
    }

    if (kDebugMode) {
      print('👂 [SocketService] Listening to event: $event');
    }

    _socket!.on(event, callback);
  }

  /// Stop listening to an event
  void off(String event) {
    if (_socket == null) return;

    if (kDebugMode) {
      print('🔇 [SocketService] Stopped listening to event: $event');
    }

    _socket!.off(event);
  }

  /// Emit an event
  void emit(String event, dynamic data) {
    if (!_isConnected || _socket == null) {
      if (kDebugMode) {
        print('⚠️ [SocketService] Cannot emit $event - Not connected');
      }
      return;
    }

    if (kDebugMode) {
      print('📤 [SocketService] Emitting event: $event with data: $data');
    }

    _socket!.emit(event, data);
  }

  /// Disconnect from socket
  void disconnect() {
    if (_socket == null) return;

    if (kDebugMode) {
      print('🔌 [SocketService] Disconnecting from Laravel Reverb');
    }

    _socket!.disconnect();
    _socket!.dispose();
    _socket = null;
    _isConnected = false;
    _isConnecting = false;
    _reconnectAttempts = 0;
  }

  /// Reconnect to socket
  Future<void> reconnect() async {
    if (kDebugMode) {
      print('🔄 [SocketService] Manually reconnecting...');
    }

    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await connect();
  }

  /// Update auth token and reconnect
  Future<void> updateAuthToken(String token) async {
    if (kDebugMode) {
      print('🔑 [SocketService] Updating auth token and reconnecting');
    }

    await setValue(tokenKey, token);
    await reconnect();
  }

  /// Get base URL for socket connection
  /// Derives from central API URL (APIRoutes.baseURL)
  String _getBaseUrl() {
    // Import not available here, so we use the same logic as getServerBaseUrl()
    // We derive from the stored baseurl or use a fallback
    String baseUrl = getStringAsync('serverBaseUrl');

    if (baseUrl.isEmpty) {
      // Fallback - derive from the API base URL constant
      // This should be set when the app initializes
      baseUrl = 'http://192.168.0.13:8000';
    }

    // Remove trailing slash
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    if (kDebugMode) {
      print('🌐 [SocketService] Base URL: $baseUrl');
    }

    return baseUrl;
  }

  /// Check if socket is healthy
  bool isHealthy() {
    return _isConnected && _socket != null && _socket!.connected;
  }

  /// Get connection status as string
  String getConnectionStatus() {
    if (_isConnecting) return 'Connecting...';
    if (_isConnected && isHealthy()) return 'Connected';
    if (_reconnectAttempts > 0) {
      return 'Reconnecting... (${_reconnectAttempts}/$_maxReconnectAttempts)';
    }
    return 'Disconnected';
  }

  /// Dispose socket service
  void dispose() {
    if (kDebugMode) {
      print('🗑️ [SocketService] Disposing socket service');
    }

    disconnect();
    onConnect = null;
    onDisconnect = null;
    onError = null;
  }
}
