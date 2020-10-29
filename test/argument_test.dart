import 'package:test/test.dart';
import 'package:ecos_communicator/src/argument.dart';

void main() {
  final types = [
    ParameterType.NATIVE,
    ParameterType.STRING,
    ParameterType.NO_VALUE,
  ];

  final typeThrow = [throwsArgumentError, throwsArgumentError, returnsNormally];

  for (var i = 0; i < types.length; i++) {
    test('constructor type ${types[0]} without value', () {
      expect(() => Argument(name: '', type: types[0]), typeThrow[1]);
    });
  }

  test('equals ok', () {
    final param1 =
        Argument(name: 'test', value: 'val', type: ParameterType.STRING);
    final param2 =
        Argument(name: 'test', value: 'val', type: ParameterType.STRING);

    expect(param1 == param2, isTrue);
  });

  test('equals wrong', () {
    final param1 =
        Argument(name: 'test', value: 'val', type: ParameterType.STRING);
    final param2 =
        Argument(name: 'test', value: 'wrong', type: ParameterType.STRING);

    expect(param1 == param2, isFalse);
  });

  final strParam = [
    ['mode[SWITCH]', Argument(name: 'mode', value: 'SWITCH')],
    [
      'name1["Weiche"]',
      Argument(name: 'name1', value: 'Weiche', type: ParameterType.STRING)
    ],
    ['position[ok]', Argument(name: 'position', value: 'ok')],
    ['name1', Argument(name: 'name1', type: ParameterType.NO_VALUE)],
    [
      r'name1["Test""\[]"]',
      Argument(name: 'name1', value: r'Test"\[]', type: ParameterType.STRING)
    ]
  ];

  for (var str in strParam) {
    test('.fromString() with ${str[0]}',
        () => {expect(Argument.fromString(str[0]), equals(str[1]))});
  }

  for (var str in strParam) {
    Argument param = str[1];
    test('.str expected ${str[0]}', () => {expect(param.str, equals(str[0]))});
  }
}
