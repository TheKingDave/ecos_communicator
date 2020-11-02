import 'dart:async';
import 'dart:collection';

import '../objects/event.dart';
import 'package:meta/meta.dart';

import '../objects/request.dart';
import 'simpleConnection.dart';
import '../objects/argument.dart';
import '../objects/reply.dart';

/// A connection to a ECoS with more sophisticated control
///
/// This class supports the direct answer of Requests and splits the Events from
/// the rest of the Reply stream so they can be listened to as a stream.
class Connection {
  final SimpleConnection _connection;
  final Queue<Completer<Reply>> _commandQueue = Queue();
  final Map<int, StreamController<Event>> _events = {};

  /// Creates a connection with a supplied [SimpleConnection]
  Connection(this._connection) {
    _connection.responses.listen(_responseHandler);
  }

  /// Creates a connection which internally creates a [SimpleConnection]
  factory Connection.raw(
      {@required address,
      port = 15471,
      pingInterval = const Duration(seconds: 1),
      timeout = const Duration(seconds: 2)}) {
    return Connection(SimpleConnection(
        address: address,
        port: port,
        pingInterval: pingInterval,
        timeout: timeout));
  }

  /// Sends a request to the ECoS and returns the [Reply] in a [Future]
  Future<Reply> send(Request request) async {
    Completer<Reply> completer;
    completer = Completer();
    _commandQueue.add(completer);
    _connection.commands.add(request);
    return completer.future;
  }

  /// Subscribes to the [Event]s of an object with the specified [id]
  ///
  /// This will return a broadcast [Stream] of [Event]s. There is always only
  /// one [Stream] per id. The view on the object will only be requested if the
  /// [Stream] is listened to. When the [Stream] gets canceled the view is
  /// released.
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

  /// Closes all event [Stream]s and closes the [BasicConnection]
  void close() async {
    _events.forEach((key, value) => value.close());
    await _connection.close();
  }
}
