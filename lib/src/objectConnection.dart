import 'dart:async';
import 'dart:collection';

import 'event.dart';
import 'package:meta/meta.dart';

import 'command.dart';
import 'connection.dart';
import 'parameter.dart';
import 'response.dart';

class ObjectConnection {
  final Connection _connection;
  final Queue<Completer<Response>> _commandQueue = Queue();
  final Map<int, StreamController<Event>> _events = {};

  ObjectConnection(this._connection) {
    _connection.responses.listen(_responseHandler);
  }

  factory ObjectConnection.raw({@required String address, int port = 15471}) {
    return ObjectConnection(Connection(address: address, port: port));
  }

  Future<Response> send(Command cmd) async {
    Completer<Response> completer;
    completer = Completer();
    _commandQueue.add(completer);
    _connection.commands.add(cmd);
    return completer.future;
  }

  Stream<Event> getEvents(int id) {
    if (_events.containsKey(id)) {
      return _events[id].stream;
    }
    final controller = StreamController<Event>.broadcast(
        onListen: () => send(Command.request(id, {Parameter.name('view')})),
        onCancel: () {
          print('onCancel $id');
          send(Command.release(id, {Parameter.name('view')}));
          _events.remove(id);
        });
    _events[id] = controller;
    return controller.stream;
  }

  void _responseHandler(Response response) {
    switch (response.type) {
      case 'REPLY':
        _replyHandler(response);
        break;
      case 'EVENT':
        _eventHandler(Event.fromResponse(response));
        break;
      default:
        print('ERROR: should never happen');
    }
  }

  void _replyHandler(Response response) {
    _commandQueue.removeFirst().complete(response);
  }

  void _eventHandler(Event event) {
    final id = event.id;
    if (!_events.containsKey(id)) {
      return;
    }
    _events[id].add(event);
  }

  void close() async {
    _connection.close();
  }
}
