import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:ecos_communicator/src/eventHandler.dart';

import 'event.dart';

import 'parameter.dart';
import 'package:meta/meta.dart';

import 'tuple.dart';
import 'command.dart';
import 'responseTransformer.dart';
import 'response.dart';
import 'connectionHandler.dart';

class Connection {
  final String address;
  final int port;
  final ConnectionHandler _connectionHandler;

  Socket _socket;
  Timer _timer;

  final List<Tuple<Command, Completer<Response>>> _commandList = [];
  final StreamController _eventStreamController = StreamController<Event>();
  final Map<int, EventHandler> _eventHandlers = {};

  String stringTransform(Uint8List data) {
    return String.fromCharCodes(data);
  }

  Connection(
      {@required this.address,
      @required this.port,
      @required ConnectionHandler connectionHandler})
      : _connectionHandler = connectionHandler;

  void open() async {
    _socket =
        await Socket.connect(address, port, timeout: Duration(seconds: 5));

    _timer = Timer.periodic(
        Duration(seconds: 1),
        (timer) => sendCommand(Command(
            type: 'get', id: 1, parameters: {Parameter.noValue('status')})));

    _socket
        .map(stringTransform)
        .transform(LineSplitter())
        .transform(ResponseTransformer())
        .timeout(Duration(seconds: 2), onTimeout: onTimeout)
        .listen(responseHandler,
            onError: errorHandler,
            onDone: () => _connectionHandler?.onDisconnect());

    _connectionHandler?.onConnect();
  }

  void onTimeout(EventSink<Response> sink) {
    print('onTimeout');
    _timer.cancel();
    _socket.close();
    sink.close();
  }

  void responseHandler(Response response) {
    if (response.type == 'EVENT') {
      _eventStreamController.add(Event.fromResponse(response));
      return;
    }
    final cmd = Command.fromString(response.extra);
    final tuple = _commandList.firstWhere((tuple) => tuple.item0 == cmd);
    _commandList.removeAt(_commandList.indexOf(tuple));
    tuple.item1.complete(response);
  }

  void errorHandler(error, StackTrace trace) {
    print('Error: $error');
  }

  Future<Response> sendCommand(Command cmd) async {
    Completer<Response> completer;
    completer = Completer();
    _commandList.add(Tuple(cmd, completer));
    _socket.write('${cmd.str}\n');
    return completer.future;
  }

  void registerEventHandler(int id, EventHandler eventHandler) async {
    if (_eventHandlers[id] != null) {
      throw StateError('Event handler with id $id already registered');
    }
    try {
      await sendCommand(Command(
          type: 'request', id: id, parameters: {Parameter.noValue('view')}));
      _eventHandlers[id] = eventHandler;
    } catch(e) {
      throw Exception('Command returned an error');
    }
  }

  void unregisterEventHandler(int id) async {
    if(_eventHandlers[id] == null) return;
    try {
      await sendCommand(Command(
          type: 'release', id: id, parameters: {Parameter.noValue('view')}));
      _eventHandlers[id] = null;
    } catch(e) {
      throw Exception('Command returned an error');
    }
  }

  Stream<Event> get events {
    return _eventStreamController.stream;
  }

  void close() {
    return _socket.destroy();
  }
}
