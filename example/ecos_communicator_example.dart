import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ecos_communicator/ecos_communicator.dart';

void main(List<String> args) {
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
  ObjectConnection _con;
  bool _state;
  StreamSubscription _stdinSub;

  Main(this.address, this.id) {
    main();
  }

  void main() async {
    // Create connection
    _con = ObjectConnection.raw(address: address);

    // Get state of object [id]
    final resp = await _con.send(Command.get(id, {Parameter.name('state')}));
    _state = resp.lines.first.parameters.first.value == '1';

    print('Switch: $swStr');

    // Make subscription to events from object [id]
    var sub = makeSub();

    // cli code
    _stdinSub =
        stdin.transform(utf8.decoder).transform(LineSplitter()).listen((line) {
      switch (line) {
        case 's':
          // Switch object 20000
          _state = !_state;
          print('Switch: $swStr');
          _con.send(
              Command.set(id, {Parameter.native('state', _state ? '1' : '0')}));
          break;
        case 'c':
          // Cancel subscription to events from [id]
          sub.cancel();
          break;
        case 'm':
          // Re establish subscription to events from [id]
          sub = makeSub();
          break;
        case 'close':
          // Close connection
          _con.close();
          _stdinSub.cancel();
          print('End');
          break;
      }
    });
  }

  /// Create subscription to events from object 20000 (switch)
  StreamSubscription makeSub() {
    return _con.getEvents(id).listen((event) {
      if (event.parameter.name == 'state') {
        _state = event.parameter.value == '1';
        print('Switch: $swStr');
      }
    });
  }

  String get swStr {
    return _state ? 'curved' : 'straight';
  }
}
