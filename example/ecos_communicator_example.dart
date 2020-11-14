import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ecos_communicator/ecos_communicator.dart';

void main(List<String> args) {
  // Check cli arguments
  if (args.isEmpty) {
    print('At least one argument is needed: <address> [<switch id: 20000>]');
    return;
  }

  final id = args.length < 2 ? 20000 : int.parse(args[1]);

  Main(args[0], id);
}

class Main {
  final String address;
  final int id;
  Connection _connection;
  bool _state;
  StreamSubscription _stdinSubscription;

  Main(this.address, this.id) {
    main();
  }

  void main() async {
    // Create connection
    _connection = Connection.raw(address: address);

    // Get state of object [id]
    final resp =
        await _connection.send(Request.get(id, {Argument.name('state')}));
    _state = resp.entries.first.arguments.first.value == '1';

    print('Switch: $swStr');

    // Make subscription to events from object [id]
    var sub = subscribeToEvents();

    // cli code
    _stdinSubscription =
        stdin.transform(utf8.decoder).transform(LineSplitter()).listen((line) {
      switch (line) {
        case 's':
          // Switch object [id]
          _state = !_state;
          print('Switch: $swStr');
          _connection.send(
              Request.set(id, {Argument.native('state', _state ? '1' : '0')}));
          break;
        case 'c':
          // Cancel subscription to events from [id]
          sub.cancel();
          break;
        case 'm':
          // Re establish subscription to events from [id]
          sub = subscribeToEvents();
          break;
        case 'close':
          // Close connection
          _connection.close();
          _stdinSubscription.cancel();
          print('End');
          break;
      }
    });
  }

  /// Create subscription to events from object 20000 (switch)
  StreamSubscription subscribeToEvents() {
    return _connection.getEvents(id).listen((event) {
      if (event.argument.name == 'state') {
        _state = event.argument.value == '1';
        print('Switch: $swStr');
      }
    });
  }

  String get swStr {
    return _state ? 'curved' : 'straight';
  }
}
