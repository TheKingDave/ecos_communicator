import 'package:test/test.dart';
import 'package:ecos_communicator/src/command.dart';
import 'package:ecos_communicator/src/parameter.dart';

void main() {
  final cmds = [
    Command(type: 'get', id: 20000),
    Command(type: 'get', id: 20000, parameters: {Parameter.name('state')}),
    Command(type: 'set', id: 20000, parameters: {
      Parameter.native('state', '1'),
      Parameter.string('name1', 'Weiche'),
      Parameter.string('name2', 'Test'),
      Parameter.string('name3', r'"[]\'),
    })
  ];

  final strs = [
    r'get(20000)',
    r'get(20000,state)',
    r'set(20000,state[1],name1["Weiche"],name2["Test"],name3["""[]\"])',
  ];

  for (var i = 0; i < cmds.length; i++) {
    final cmd = cmds[i];
    final str = strs[i];

    test('.str $str}', () => expect(cmd.str, equals(str)));

    test('.fromString ${str}',
        () => expect(Command.fromString(str), equals(cmd)));

    test('equal ${strs[i]}',
        () => expect(cmd == Command.fromString(str), isTrue));
  }

  test('wrong command string',
      () => {expect(() => Command.fromString('test'), throwsArgumentError)});
}
