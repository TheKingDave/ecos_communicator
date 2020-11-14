import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../objects/request.dart';
import '../objects/response.dart';
import 'connectionSettings.dart';
import 'responseTransformer.dart';

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
/// [pingInterval] sets the time interval where a ping is sent to the ECoS
/// this is done by using the command `test("#ping")` which the ECoS will answer
/// to with `#ping`.
///
/// [timeout] sets the time until the connection will be closed if no message is
/// received within this time.
class SimpleConnection {
  /// The connection settings
  final ConnectionSettings settings;

  Socket _socket;
  Timer _timer;
  bool _isClosed = false;

  StreamController<Response> _responseController;

  /// Stream of responses gotten from the ECoS
  Stream<Response> get responses => _responseController.stream;

  StreamController<Request> _commandController;

  /// Sink to send commands to the ECoS
  StreamSink<Request> get commands => _commandController.sink;

  /// Creates a connection, the socket will only be open if the [open()] method
  /// is called
  SimpleConnection(this.settings) {
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
    Socket.connect(settings.address, settings.port).then(_onOpen);
  }

  void _onOpen(Socket socket) {
    _socket = socket;

    if (settings.pingInterval != null) {
      _timer =
          Timer.periodic(settings.pingInterval, (_) => _send('test("#ping")'));
    }

    var stream = _socket
        .map((data) => String.fromCharCodes(data))
        .transform(LineSplitter());

    if (settings.timeout != null) {
      stream = stream.timeout(settings.timeout, onTimeout: _onTimeout);
    }

    stream
        .where((line) => line[0] != '#') // ignore comments
        .transform(ResponseTransformer())
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
