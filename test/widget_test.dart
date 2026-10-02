import 'package:flutter_test/flutter_test.dart';
import 'package:door_to_door_shipping/main.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DoorToDoorApp());
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Continue (stub)'), findsOneWidget);
  });
}
