import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bank_employee_details_frontend/main.dart';

void main() {
  testWidgets('BankEmployeeApp desktop test renders sidebar, navigation and title', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const BankEmployeeApp());
    await tester.pumpAndSettle();

    expect(find.text('APEX GLOBAL BANK'), findsOneWidget);
    expect(find.text('Add Employee'), findsWidgets);
    expect(find.text('View Employees'), findsWidgets);
    expect(find.text('Employee Registration Form'), findsOneWidget);
  });

  testWidgets('BankEmployeeApp mobile test renders bottom navigation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const BankEmployeeApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Add Employee'), findsWidgets);
    expect(find.text('View Employees'), findsWidgets);
  });
}
