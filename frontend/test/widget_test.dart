import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/main.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const FlippedClassroomApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
