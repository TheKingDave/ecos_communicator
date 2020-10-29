import 'dart:async';
import 'dart:collection';

import 'event.dart';
import 'package:meta/meta.dart';

import 'request.dart';
import 'connection.dart';
import 'argument.dart';
import 'reply.dart';

class ObjectConnection {
  final Connection _connection;
  final Queue<Completer<Reply>> _commandQueue = Queue();
  final Map<int, StreamController<Event>> _events = {};

  ObjectConnection(this._connection) {
    _connection.responses.listen(_responseHandler);
  }

  factory ObjectConnection.raw({@required String address, int port = 15471}) {
    return ObjectConnection(Connection(address: address, port: port));
  }

  Future<Reply> send(Request cmd) async {
    Completer<Reply> completer;
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
        onListen: () => send(Request.request(id, {Argument.name('view')})),
        onCancel: () {
          send(Request.release(id, {Argument.name('view')}));
          _events.remove(id);
        });
    _events[id] = controller;
    return controller.stream;
  }

  void _responseHandler(Reply response) {
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

  void _replyHandler(Reply response) {
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
    // Close all event streams
    _events.forEach((key, value) => value.close());
    await _connection.close();
  }
}
