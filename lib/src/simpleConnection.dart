import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import 'request.dart';
import 'reply.dart';
import 'replyTransformer.dart';

/// A basic connection to the ECoS with type parsing
///
/// This class will connect to the supplied [address] and [port].
///
/// This connection will be established when the [responses] stream gets
/// listened to or the [open()] method is called.
///
/// The connection supports the features ping and timeout. These features can be
/// independently turned on or off.
///
/// [pingInterval] sets the time time interval where a ping is sent to the ECoS
/// this is done by using the command `test("#ping")` which the ECoS will answer
/// to with `#ping`.
///
/// [timeout] sets the time until the connection will be closed if no message is
/// received within this time.
class SimpleConnection {
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
  bool _isClosed = false;

  StreamController<Reply> _responseController;

  /// Stream of responses gotten from the ECoS
  Stream<Reply> get responses => _responseController.stream;

  StreamController<Request> _commandController;

  /// Sink to send commands to the ECoS
  StreamSink<Request> get commands => _commandController.sink;

  /// Creates a connection, the socket will only be open if the [open()] method
  /// is called
  SimpleConnection(
      {@required this.address,
      this.port = 15471,
      this.pingInterval = const Duration(seconds: 1),
      this.timeout = const Duration(seconds: 2)}) {
    _responseController = StreamController(onListen: open);
    _commandController = StreamController();
  }

  /// Opens the socket
  ///
  /// This method is automatically called when the [commands] stream is listened
  /// to
  ///
  /// If the socket is already opened it does nothing
  void open() {
    if (_socket != null) return;
    Socket.connect(address, port).then(_onOpen);
  }

  void _onOpen(Socket socket) {
    _socket = socket;

    if (pingInterval != null) {
      _timer = Timer.periodic(pingInterval, (_) => _send('test("#ping")'));
    }

    var stream = _socket
        .map((data) => String.fromCharCodes(data))
        .transform(LineSplitter());

    if (timeout != null) {
      stream = stream.timeout(timeout, onTimeout: _onTimeout);
    }

    stream
        .where((line) => line[0] != '#') // ignore comments
        .transform(ReplyTransformer())
        .pipe(_responseController);

    _commandController.stream.listen(_onCommand);
  }

  void _onCommand(Request request) {
    _send(request.str);
  }

  void _send(String str) {
    if (_isClosed) return;
    _socket.write('${str}\n');
  }

  void _onTimeout(EventSink sink) {
    sink.close();
    close();
  }

  /// Closes the socket and all streams
  void close() async {
    if (_isClosed) return;
    _isClosed = true;
    _timer?.cancel();
    await _socket.close();
    _socket.destroy();
    await _commandController.close();
  }
}
