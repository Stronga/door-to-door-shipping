import 'package:door_to_door_shipping/services/label_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a plain three-line label', () {
    final parsed = parseLabelText('''
Kwame Mensah
+233 24 123 4567
Kumasi
''');
    expect(parsed.receiverName, 'Kwame Mensah');
    expect(parsed.phone, '+233 24 123 4567');
    expect(parsed.destination, 'Kumasi');
  });

  test('parses prefixed lines and keeps a person name off the destination', () {
    final parsed = parseLabelText('''
TO: Ama Serwaa
PHONE: (347) 555-0199
DESTINATION: Accra, Ghana
''');
    expect(parsed.receiverName, 'Ama Serwaa');
    expect(parsed.phone, '(347) 555-0199');
    expect(parsed.destination, 'Accra, Ghana');
  });

  test('treats a city after TO as the destination, not a name', () {
    final parsed = parseLabelText('TO: Kumasi\n555-010-0199');
    expect(parsed.receiverName, isNull);
    expect(parsed.destination, 'Kumasi');
    expect(parsed.phone, '555-010-0199');
  });

  test('empty text yields empty fields', () {
    final parsed = parseLabelText('   \n');
    expect(parsed.receiverName, isNull);
    expect(parsed.phone, isNull);
    expect(parsed.destination, isNull);
  });
}
