import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utspraktikum/main.dart';

void main() {
  testWidgets('App displays weather home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Cari nama kota...'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
