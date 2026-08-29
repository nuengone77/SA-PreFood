// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prefood/main.dart';

void main() {
  testWidgets('welcome opens login and customer dashboard', (tester) async {
    await tester.pumpWidget(const PreFoodApp());

    expect(find.text('PreFood'), findsOneWidget);
    expect(find.text('สั่งก่อน อร่อยได้ตรงเวลา'), findsOneWidget);

    await tester.tap(find.byKey(const Key('welcome-login')));
    await tester.pumpAndSettle();
    expect(find.text('ยินดีต้อนรับกลับ 👋'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('หิวอะไรดีวันนี้?'), findsOneWidget);
    expect(find.text('ร้านแนะนำ'), findsOneWidget);
  });

  testWidgets('vendor role opens vendor dashboard', (tester) async {
    await tester.pumpWidget(const PreFoodApp());
    await tester.tap(find.byKey(const Key('welcome-login')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('role-vendor')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('สวัสดีตอนเที่ยง 👋'), findsOneWidget);
    expect(find.text('โหมดร้านค้า'), findsOneWidget);
  });

  testWidgets('admin role opens admin console', (tester) async {
    await tester.pumpWidget(const PreFoodApp());
    await tester.tap(find.byKey(const Key('welcome-login')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('role-admin')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('ภาพรวมระบบ'), findsOneWidget);
    expect(find.text('สวัสดี, ผู้ดูแลระบบ'), findsOneWidget);
  });
}
