import 'package:meta/meta.dart';

/// The settings for connection to a ECoS
class ConnectionSettings {
  /// The address (ip) of the ECoS
  final String address;

  /// The port to connect to (default: 15471)
  final int port;

  /// The interval between sending pings to the ECoS
  final Duration pingInterval;

  /// How long until the timeout is reached
  final Duration timeout;

  /// Creates a [ConnectionSettings] from the supplied parameters
  ConnectionSettings(
      {@required this.address,
      this.port = 15471,
      this.pingInterval = const Duration(seconds: 1),
      this.timeout = const Duration(seconds: 2)});
}
