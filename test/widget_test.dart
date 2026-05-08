import 'package:flutter_test/flutter_test.dart';
import 'package:piloto/main.dart';

void main() {
  testWidgets('TaskFlow smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
  });
}
