// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:media_handler/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app loads with MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);

    // Pump a few frames to allow providers to initialize
    await tester.pump();
    await tester.pump();
    await tester.pump();

    // App should be initialized without crashing
    expect(tester.takeException(), isNull);
  });
}
