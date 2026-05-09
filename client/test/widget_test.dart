import 'package:client/app/load_balancer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders the load balancer dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const LoadBalancerApp());

    expect(find.text('Load Balancer Dashboard'), findsOneWidget);
    expect(find.text('Send Request'), findsOneWidget);
    expect(find.byIcon(Icons.public), findsOneWidget);
  });
}
