import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('ElectricalAI Pro app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ElectricalAIProApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.textContaining('ElectricalAI'), findsWidgets);
    expect(find.text('PRO'), findsOneWidget);
  });
}
