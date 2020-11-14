import 'package:ecos_communicator/ecos_communicator.dart';
import 'package:ecos_communicator/src/connection/connectionSettings.dart';

void main() async {
  // Create a connection
  final connection = Connection(ConnectionSettings(address: '192.168.0.26'));

  print('Create new locomotive');

  // Send a create request
  final reply = await connection.send(Request.create(10, {
    Argument.native('addr', '10'),
    Argument.string('name', 'Test'),
    Argument.native('protocol', 'DCC128'),
    Argument.name('append')
  }));

  // Get the id of the newly created locomotive
  final newId = int.parse(reply.entries.first.argument.value);

  print('New locomotive id: $newId');
  print('Set speed to 126');

  // Set speed of new locomotive
  await connection
      .send(Request.set(newId, {Argument.native('speedstep', '126')}));

  print('Delete created loco');

  // Send delete request
  await connection.send(Request.delete(newId));

  print('Deleted locomotive');

  try {
    // Send command which will result in an error
    await connection.send(Request.get(20000, {Argument.name('status')}));
  } on ReplyError catch (e) {
    print('ReplyError: $e');
  }

  // Close the connection
  await connection.close();
}