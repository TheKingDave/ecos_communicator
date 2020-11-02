A library to easily communicate with the [ECoS](https://www.esu.eu/en/products/digital-control/ecos-50210-dcc-system/what-ecos-can-do/) command station.

## Usage

```dart
import 'package:ecos_communicator/ecos_communicator.dart';

void main() async {
  // Create a connection
  final connection = Connection.raw(address: '192.168.0.26');

  print('Create new loco');
  
  // Send a create request
  final resp = await connection.send(Request.create(10, {
    Argument.native('addr', '10'),
    Argument.string('name', 'Test'),
    Argument.native('protocol', 'DCC128'),
    Argument.name('append')
  }));
  
  // Get the id of the newly created locomotive
  final newId = int.parse(resp.entries.first.parameters.first.value);
  
  print('New loco id: $newId');
  print('Set speed to 126');
  
  // Set speed of new locomotive
  await connection.send(Request.set(newId, {
    Argument.native('speedstep', '126')
  }));
  
  print('Delete created loco');
  
  // Send delete request
  await connection.send(Request.delete(newId));
  
  print('Deleted loco');
  
  try {
    // Send command which will result in an error
    await connection.send(Request.get(20000, {Argument.name('status')}));
  } on ReplyError catch(e) {
    print('ReplyError: $e');
  }

  // Close the connection
  await connection.close();
}
```

## Example

The example can be run with `dart ecos_communicator_example.dart <ip address> [<id: 20000>]`.

Will only work on turnouts with 2 states (normal turnouts)

This will connect to the ECoS and present a cli interface.
Updated on the turnout state will be printed in this way:
`Switch: straight` or `Switch: curved`

* `s`: Will switch the turnout
* `c`: Will disconnect the listener on turnout updates
* `m`: Will reconnect the listener on turnout updates
* `close`: Will close the connection

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/TheKingDave/ecos_communicator/issues
