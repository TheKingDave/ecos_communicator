import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import 'command.dart';
import 'response.dart';
import 'responseTransformer.dart';

class Connection {
  /// The address (ip) of the ECoS
  final String address;

  /// The port to connect to (default: 15471)
  final int port;

  /// The interval between sending pings to the ECoS
  final Duration pingInterval;

  /// How long until the timeout is reached
  final Duration timeout;

  Socket _socket;
  Timer _timer;

  StreamController<Response> _responseController;

  /// Stream of responses gotten from the ECoS
  Stream<Response> get responses => _responseController.stream;

  StreamController<Command> _commandController;

  /// Sink to send commands to the ECoS
  StreamSink<Command> get commands => _commandController.sink;

  /// Creates a connection, the socket will only open if the [open] method is called
  Connection(
      {@required this.address,
      this.port = 15471,
      this.pingInterval = const Duration(seconds: 1),
      this.timeout = const Duration(seconds: 2)}) {
    _responseController = StreamController(onListen: open);
    _commandController = StreamController();
  }

  /// Opens the socket
  ///
  /// This method is automatically called when the [commands] stream is listened to
  ///
  /// If the socket is already opened it does nothing
  void open() {
    if (_socket != null) return;
    Socket.connect(address, port).then(_onOpen);
  }

  void _onOpen(Socket socket) {
    _socket = socket;

    if (pingInterval != null) {
      _timer =
          Timer.periodic(pingInterval, (_) => _socket.write('test("#ping")\n'));
    }

    var stream = _socket
        .map((data) => String.fromCharCodes(data))
        .transform(LineSplitter());

    if (timeout != null) {
      stream = stream.timeout(timeout, onTimeout: _onTimeout);
    }

    stream
        .where((line) => line[0] != '#') // ignore comments
        .transform(ResponseTransformer())
        .pipe(_responseController);

    _commandController.stream.listen(_onCommand);
  }

  void _onCommand(Command cmd) {
    _send(cmd.str);
  }

  void _send(String str) {
    _socket.write('${str}\n');
  }

  void _onTimeout(EventSink sink) {
    sink.close();
    close();
  }

  /// Closes the socket
  void close() async {
    _timer?.cancel();
    await _socket.close();
    _socket.destroy();
    await _commandController.close();
  }
}
