import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prefood/app_store.dart';
import 'package:prefood/main.dart';
import 'package:prefood/models/models.dart';
import 'package:prefood/screens/customer/order_status_screen.dart';

/// เปิดแอป เข้าหน้า Login เลือกบทบาท แล้วกดเข้าสู่ระบบ
Future<void> loginAs(WidgetTester tester, AppRole role) async {
  await tester.pumpWidget(const PreFoodApp());
  await tester.tap(find.byKey(const Key('welcome-login')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('role-${role.name}')));
  await tester.pump();
  await tester.ensureVisible(find.byKey(const Key('login-submit')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('login-submit')));
  await tester.pumpAndSettle();
}

/// แตะ widget หลังเลื่อนรายการแนวตั้งจนมองเห็น
/// (ListView สร้าง widget เฉพาะส่วนที่อยู่ใกล้จอ จึงต้องเลื่อนหาก่อน)
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .last,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// กดปุ่มชำระเงิน หน้าสแกนจ่ายมี spinner หมุนตลอด จึงใช้ pumpAndSettle ไม่ได้
Future<void> tapPay(WidgetTester tester) async {
  final pay = find.byKey(const Key('pay-now'));
  await tester.scrollUntilVisible(
    pay,
    200,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
  await tester.tap(pay);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// รอให้ระบบจำลองตรวจพบยอดโอน แล้วไปหน้าใบเสร็จ
Future<void> payAndWait(WidgetTester tester) async {
  await tester.pump(AppStore.paymentDetectDelay);
  await tester.pump();
  expect(find.text('ได้รับเงินแล้ว'), findsOneWidget);
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  setUp(appStore.reset);

  testWidgets('welcome opens login and customer dashboard', (tester) async {
    await tester.pumpWidget(const PreFoodApp());

    expect(find.text('PreFood'), findsOneWidget);
    expect(find.text('สั่งก่อน อร่อยได้ตรงเวลา'), findsOneWidget);

    await tester.tap(find.byKey(const Key('welcome-login')));
    await tester.pumpAndSettle();
    expect(find.text('จองอาหารต้อง PreFood'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('หิวอะไรดีวันนี้?'), findsOneWidget);
    expect(find.text('ร้านแนะนำ'), findsOneWidget);
  });

  testWidgets('customer orders with note, pays by slip and gets a receipt', (
    tester,
  ) async {
    await loginAs(tester, AppRole.customer);

    await tester.tap(find.text('ครัวป้าแดง'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-f1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ไม่เผ็ด'));
    await tester.pump();
    await tapVisible(tester, find.byKey(const Key('confirm-add')));

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-cart')));
    await tester.pumpAndSettle();
    expect(find.text('หมายเหตุ: ไม่เผ็ด'), findsOneWidget);
    expect(find.text('วันและเวลานัดรับอาหาร'), findsOneWidget);

    await tapVisible(tester, find.byKey(const Key('cart-checkout')));
    expect(find.text('ชำระเงิน'), findsOneWidget);

    // กดชำระ แล้วระบบตรวจยอดโอนเองโดยไม่ต้องแนบสลิป
    await tapPay(tester);
    expect(find.text('รอการชำระเงิน'), findsOneWidget);
    expect(find.text('พร้อมเพย์ 0105569012345'), findsOneWidget);
    await payAndWait(tester);

    expect(find.text('ส่งคำสั่งซื้อเรียบร้อย'), findsOneWidget);
    expect(find.text('#A1043'), findsOneWidget);
    expect(find.text('ยืนยันแล้ว'), findsOneWidget);
    expect(find.text('PreFood (บจก. พรีฟู้ด)'), findsOneWidget);

    final order = appStore.vendorOrders.firstWhere((o) => o.id == '#A1043');
    expect(order.items, 'ข้าวกะเพราไก่ไข่ดาว x1 (ไม่เผ็ด)');
    expect(order.queueNumber, 43);
  });

  testWidgets('vendor marks menu sold out and customer sees it', (
    tester,
  ) async {
    final item = appStore.vendorShop.menu.first;
    appStore.saveMenuItem(
      AppStore.vendorShopId,
      item.copyWith(isAvailable: false),
    );

    await loginAs(tester, AppRole.customer);
    await tester.tap(find.text('ครัวป้าแดง'));
    await tester.pumpAndSettle();
    expect(find.text('สินค้าหมด'), findsOneWidget);
  });

  testWidgets('vendor accepts order and payment becomes verified', (
    tester,
  ) async {
    await loginAs(tester, AppRole.vendor);
    expect(find.text('สวัสดีตอนเที่ยง 👋'), findsOneWidget);
    expect(find.text('โหมดร้านค้า'), findsOneWidget);

    await tester.tap(find.text('ออเดอร์').last);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('accept-#A1042')));

    final order = appStore.vendorOrders.firstWhere((o) => o.id == '#A1042');
    expect(order.stage, OrderStage.cooking);
    expect(order.paymentStatus, PaymentStatus.verified);
  });

  testWidgets('vendor sales report switches period', (tester) async {
    await loginAs(tester, AppRole.vendor);
    await tester.tap(find.text('รายงาน'));
    await tester.pumpAndSettle();
    expect(find.text('฿1,245'), findsWidgets);
    await tester.tap(find.text('รายเดือน'));
    await tester.pumpAndSettle();
    expect(find.text('฿18,420'), findsWidgets);
    // ยอดสุทธิหลังหักค่าธรรมเนียมตาม PlatformConfig.feePercent
    final net = (18420 - PlatformConfig.feeFor(18420)).round().toString();
    final formatted = net.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    expect(find.text('฿$formatted'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('การโอนเงินจาก PreFood'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('เมนูขายดี'), findsOneWidget);
  });

  testWidgets('register requires student id and phone', (tester) async {
    await tester.pumpWidget(const PreFoodApp());
    await tester.tap(find.byKey(const Key('welcome-login')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('สมัครสมาชิก'));

    expect(find.text('รหัสนิสิต/รหัสบุคลากร'), findsOneWidget);
    expect(find.text('หมายเลขโทรศัพท์'), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('register-submit')));
    expect(find.text('กรุณากรอกข้อมูล'), findsWidgets);
    expect(find.text('กรุณากรอกเบอร์โทรศัพท์'), findsOneWidget);
  });

  test('points: redeem capped at 50%, refund on reject, earn on complete', () {
    final shop = appStore.vendorShop;
    final lines = [CartLine(item: shop.menu[0])]; // ฿55
    expect(appStore.points, 12);
    // ใช้ได้ไม่เกิน 50% ของ ฿55 = 27 แต่มีแค่ 12 แต้ม
    expect(appStore.redeemableFor(55), 12);
    expect(appStore.redeemableFor(20), 10);

    final order = appStore.placeOrder(
      shop: shop,
      lines: lines,
      pickupAt: DateTime.now(),
      paymentMethod: PaymentMethod.promptPay,
      pointsUsed: 12,
    );
    expect(order.total, 43);
    expect(appStore.points, 0);

    appStore.rejectOrder(order);
    expect(appStore.points, 12);
    expect(order.paymentStatus, PaymentStatus.refunded);

    final paid = appStore.placeOrder(
      shop: shop,
      lines: lines,
      pickupAt: DateTime.now(),
      paymentMethod: PaymentMethod.promptPay,
      pointsUsed: 10,
    );
    appStore.acceptOrder(paid);
    appStore.updateStage(paid, OrderStage.ready);
    appStore.updateStage(paid, OrderStage.completed);
    // จ่ายจริง ฿45 ได้ 4 แต้ม: เหลือ 2 + 4 = 6
    expect(paid.pointsEarned, 4);
    // ร้านได้ค่าอาหารเต็มหักค่าธรรมเนียม ส่วนลดจากแต้มเป็นภาระของแพลตฟอร์ม
    expect(paid.shopPayout, 55 - PlatformConfig.feeFor(55));
    expect(appStore.points, 6);
    // เปลี่ยนเป็นสำเร็จซ้ำต้องไม่ได้แต้มเพิ่ม
    appStore.updateStage(paid, OrderStage.completed);
    expect(appStore.points, 6);
  });

  testWidgets('customer uses points as a discount at payment', (tester) async {
    await loginAs(tester, AppRole.customer);
    await tester.tap(find.text('ครัวป้าแดง'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-f1')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('confirm-add')));
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-cart')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('cart-checkout')));

    await tapVisible(tester, find.byKey(const Key('use-points')));
    expect(find.text('-฿12'), findsOneWidget);
    expect(find.text('฿43'), findsWidgets);
    await tapPay(tester);
    expect(find.text('฿43'), findsOneWidget);
    await payAndWait(tester);

    expect(find.text('ส่งคำสั่งซื้อเรียบร้อย'), findsOneWidget);
    expect(appStore.points, 0);
  });

  test('order is paid on creation and shop payout excludes fee', () {
    final order = appStore.placeOrder(
      shop: appStore.vendorShop,
      lines: [CartLine(item: appStore.vendorShop.menu[0], quantity: 2)],
      pickupAt: DateTime.now(),
      paymentMethod: PaymentMethod.bankTransfer,
    );
    expect(order.paymentStatus, PaymentStatus.verified);
    appStore.acceptOrder(order);
    expect(order.stage, OrderStage.cooking);
    expect(order.platformFee, PlatformConfig.feeFor(110));
    expect(order.shopPayout, 110 - PlatformConfig.feeFor(110));
  });

  test('payout date is the configured day of the next month', () {
    expect(
      PlatformConfig.payoutDateFor(DateTime(2026, 12, 20)),
      DateTime(2027, 1, PlatformConfig.payoutDay),
    );
  });

  testWidgets('status screen updates on the first status change', (
    tester,
  ) async {
    final order = appStore.vendorOrders.firstWhere((o) => o.id == '#A1042');
    await tester.pumpWidget(MaterialApp(home: OrderStatusScreen(order: order)));
    expect(find.text('รอยืนยัน'), findsWidgets);
    appStore.acceptOrder(order);
    await tester.pumpAndSettle();
    // หัวข้อสถานะและ SnackBar แจ้งเตือนต้องเปลี่ยนตั้งแต่ครั้งแรก
    expect(find.text('#A1042: กำลังปรุงอาหาร'), findsOneWidget);
    expect(find.text('ร้านกำลังปรุงอาหารของคุณ'), findsOneWidget);
  });

  testWidgets('admin role opens admin console', (tester) async {
    await loginAs(tester, AppRole.admin);
    expect(find.text('ภาพรวมระบบ'), findsOneWidget);
    expect(find.text('สวัสดี, ผู้ดูแลระบบ'), findsOneWidget);
  });
}
