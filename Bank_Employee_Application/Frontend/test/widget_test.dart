// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('BankCustomerApp desktop test renders sidebar, navigation and title', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const BankCustomerApp());
    await tester.pumpAndSettle();

    expect(find.text('APEX GLOBAL BANK'), findsOneWidget);
    expect(find.text('Add Customer'), findsWidgets);
    expect(find.text('View Customers'), findsWidgets);
    expect(find.text('Add New Customer'), findsOneWidget);
  });

  testWidgets('BankCustomerApp mobile test renders bottom navigation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const BankCustomerApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Add Customer'), findsWidgets);
    expect(find.text('View Customers'), findsWidgets);
  });

  testWidgets('Navigating to View Customers displays backend disconnected message', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const BankCustomerApp());
    await tester.pumpAndSettle();

    // Click on View Customers in sidebar
    await tester.tap(find.text('View Customers').first);
    await tester.pumpAndSettle();

    // Check for the mandated message
    expect(
      find.text('Customer data is not connected yet. Please connect the backend to view customer records.'),
      findsOneWidget,
    );
    expect(find.text('Search Customer by ID'), findsOneWidget);
  });
}
