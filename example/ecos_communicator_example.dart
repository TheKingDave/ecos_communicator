import 'package:ecos_communicator/ecos_communicator.dart';

void main() {
  Main();
}

class Main extends ConnectionHandler {
  Connection _connection;
  bool open = true;

  Main() {
    _connection = Connection(
        address: '192.168.0.26', port: 15471, connectionHandler: this);
    _connection.events.listen((event) => print(event));

    connect();
  }

  void connect() async {
    try {
      await _connection.open();
    } catch (e) {
      print(e);
    }
  }

  @override
  void onConnect() async {
    print('onConnect');

    print(await _connection.sendCommand(Command(
        type: 'request', id: 20000, parameters: {Parameter.noValue('view')})));

    /*while (open) {
      print(await _connection.sendCommand(Command(
          type: 'get', id: 20000, parameters: {Parameter.noValue('name1')})));
      await Future.delayed(Duration(seconds: 1));
    }*/

    //connection.close();
  }

  @override
  void onDisconnect() {
    print('onDisconnect');
    open = false;
  }
}
