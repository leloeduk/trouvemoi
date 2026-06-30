import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a minimal widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('TrouveMoi')),
      ),
    );

    expect(find.text('TrouveMoi'), findsOneWidget);
  });
}
