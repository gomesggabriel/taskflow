import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_project/main.dart';

void main() {
  testWidgets('TaskFlow smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
  });
}
