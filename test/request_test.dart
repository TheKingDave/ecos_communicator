import 'package:test/test.dart';
import 'package:ecos_communicator/src/objects/request.dart';
import 'package:ecos_communicator/src/objects/argument.dart';

void main() {
  final cmds = [
    Request(command: 'get', id: 20000),
    Request(command: 'get', id: 20000, arguments: {Argument.name('state')}),
    Request(command: 'set', id: 20000, arguments: {
      Argument.native('state', '1'),
      Argument.string('name1', 'Weiche'),
      Argument.string('name2', 'Test'),
      Argument.string('name3', r'"[,]\'),
    })
  ];

  final strs = [
    r'get(20000)',
    r'get(20000,state)',
    r'set(20000,state[1],name1["Weiche"],name2["Test"],name3["""[,]\"])',
  ];

  for (var i = 0; i < cmds.length; i++) {
    final cmd = cmds[i];
    final str = strs[i];

    test('.str $str}', () => expect(cmd.str, equals(str)));

    test('.fromString ${str}',
        () => expect(Request.fromString(str), equals(cmd)));

    test('equal ${strs[i]}',
        () => expect(cmd == Request.fromString(str), isTrue));
  }

  test('wrong command string',
      () => {expect(() => Request.fromString('test'), throwsArgumentError)});
}
