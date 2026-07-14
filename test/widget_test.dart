import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice/main.dart';

void main() {
  testWidgets('SpiceRoute login screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SpiceRouteApp());
    expect(find.text('SpiceRoute'), findsOneWidget);
    expect(find.text('Continue to Menu'), findsOneWidget);
  });
}
