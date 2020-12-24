import 'package:ecos_communicator/ecos_communicator.dart';
import 'package:test/test.dart';

void main() {
  test('complete get reply', () {
    final expected = Response(
        type: 'REPLY',
        extra: 'get(20032)',
        status: 0,
        statusMsg: 'OK',
        entries: [
          ListEntry(id: 20032, arguments: [Argument.native('addr', '1')]),
          ListEntry(
              id: 20032, arguments: [Argument.string('name1', '1 Double')]),
          ListEntry(id: 20032, arguments: [Argument.string('name2', 'Left')]),
          ListEntry(id: 20032, arguments: [Argument.string('name3', '')]),
        ]);

    final resp = Response.fromString('''<REPLY get(20032)>
20032 addr[1]
20032 name1["1 Double"]
20032 name2["Left"]
20032 name3[""]
<END 0 (OK)>''');

    expect(resp == expected, isTrue);
  });

  test('complete queryObjects', () {
    final expected = Response(
        type: 'REPLY',
        extra: 'queryObjects(11, name1, name2, name3)',
        status: 0,
        statusMsg: 'OK',
        entries: [
          ListEntry(id: 20032, arguments: [
            Argument.string('name1', '1 Double'),
            Argument.string('name2', 'Left'),
            Argument.string('name3', '')
          ]),
          ListEntry(id: 20002, arguments: [
            Argument.string('name1', '2 Signal'),
            Argument.string('name2', ''),
            Argument.string('name3', 'Test"hallo')
          ]),
        ]);

    final resp =
        Response.fromString('''<REPLY queryObjects(11, name1, name2, name3)>
20032 name1["1 Double"] name2["Left"] name3[""]
20002 name1["2 Signal"] name2[""] name3["Test""hallo"]
<END 0 (OK)>''');

    expect(resp == expected, isTrue);
  });
}
