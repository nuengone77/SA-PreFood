import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:prefood/app_store.dart';
import 'package:prefood/main.dart';

/// เดินผ่านทุก process ของแอปบนอุปกรณ์จริง/Simulator แล้วเก็บภาพหน้าจอ
/// ใช้ทำภาพประกอบรายงาน รันด้วย:
/// flutter drive --driver=test_driver/integration_test.dart \
///   --target=integration_test/screenshots_test.dart -d DEVICE_ID
/// ภาพจะถูกบันทึกที่ screenshots/
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  var counter = 0;

  /// ถ่ายภาพหน้าจอ ตั้งชื่อไฟล์เรียงลำดับตามขั้นตอน
  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pump();
    // รอให้เฟรมใหม่ขึ้นจอจริงก่อนถ่าย ไม่งั้นอาจได้ภาพเฟรมก่อนหน้า
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await tester.pump();
    counter++;
    await binding.takeScreenshot('${counter.toString().padLeft(2, '0')}_$name');
  }

  /// รอเวลาจริง (เช่น timer จำลองการตรวจยอดโอน) แล้ววาดเฟรมใหม่
  Future<void> wait(WidgetTester tester, Duration duration) async {
    await Future<void>.delayed(duration);
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester) =>
      tester.pumpAndSettle(const Duration(milliseconds: 100));

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await settle(tester);
    await tester.tap(finder);
    await settle(tester);
  }

  /// เลื่อนรายการแนวตั้งจนเห็น [finder]
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .last,
    );
    await settle(tester);
  }

  void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  Future<void> login(WidgetTester tester, String role) async {
    await tap(tester, find.byKey(const Key('welcome-login')));
    await tap(tester, find.byKey(Key('role-$role')));
    await tap(tester, find.byKey(const Key('login-submit')));
  }

  Future<void> logoutTo(WidgetTester tester, Finder logoutButton) async {
    await scrollTo(tester, logoutButton);
    await tap(tester, logoutButton);
  }

  testWidgets('capture every process', (tester) async {
    appStore.reset();
    await tester.pumpWidget(const PreFoodApp());
    await settle(tester);

    // ---------- เข้าสู่ระบบ / สมัครสมาชิก ----------
    await shot(tester, 'splash');
    await tap(tester, find.byKey(const Key('welcome-login')));
    await shot(tester, 'login_customer');
    await tap(tester, find.byKey(const Key('role-vendor')));
    await shot(tester, 'login_vendor');
    await tap(tester, find.byKey(const Key('role-admin')));
    await shot(tester, 'login_admin');
    await tap(tester, find.byKey(const Key('role-customer')));

    await tap(tester, find.text('สมัครสมาชิก'));
    await shot(tester, 'register_customer');
    await tap(tester, find.byKey(const Key('register-submit')));
    await scrollTo(tester, find.text('สร้างบัญชี'));
    await shot(tester, 'register_validation');
    await tap(tester, find.text('ร้านค้า'));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await settle(tester);
    await shot(tester, 'register_vendor');
    await tester.pageBack();
    await settle(tester);

    // ---------- ลูกค้า: ค้นหาและเลือกเมนู ----------
    await tap(tester, find.byKey(const Key('login-submit')));
    await shot(tester, 'customer_home');
    await tester.enterText(find.byType(TextField).first, 'กะเพรา');
    hideKeyboard();
    await settle(tester);
    await shot(tester, 'customer_search_menu');
    await tester.enterText(find.byType(TextField).first, '');
    hideKeyboard();
    await settle(tester);

    await tap(tester, find.text('ครัวป้าแดง'));
    await shot(tester, 'shop_menu');
    await tap(tester, find.byKey(const Key('add-f1')));
    await tap(tester, find.text('ไม่เผ็ด'));
    await tester.enterText(find.byKey(const Key('item-note')), 'ไข่ดาวไม่สุก');
    hideKeyboard();
    await settle(tester);
    await shot(tester, 'add_to_cart_options');
    await tap(tester, find.byKey(const Key('confirm-add')));
    await tap(tester, find.byKey(const Key('add-f2')));
    await tap(tester, find.byKey(const Key('confirm-add')));
    await wait(tester, const Duration(seconds: 1));
    await tester.pageBack();
    await settle(tester);

    // ---------- ตะกร้าและเลือกวันเวลารับ ----------
    await tap(tester, find.byKey(const Key('nav-cart')));
    await shot(tester, 'cart');
    final noon = find.widgetWithText(ChoiceChip, '12:00');
    await scrollTo(tester, noon);
    await tap(tester, noon);
    await scrollTo(tester, find.byKey(const Key('cart-checkout')));
    await shot(tester, 'cart_pickup_time');

    // ---------- ชำระเงิน ----------
    await tap(tester, find.byKey(const Key('cart-checkout')));
    await shot(tester, 'payment');
    await tap(tester, find.byKey(const Key('use-points')));
    await shot(tester, 'payment_use_points');

    final pay = find.byKey(const Key('pay-now'));
    await scrollTo(tester, pay);
    await tester.tap(pay);
    // หน้าสแกนจ่ายมี spinner หมุนตลอด จึงรอด้วยเวลาแทน pumpAndSettle
    await wait(tester, const Duration(milliseconds: 700));
    await shot(tester, 'payment_qr_waiting');
    await wait(tester, AppStore.paymentDetectDelay);
    await shot(tester, 'payment_detected');
    await wait(tester, const Duration(seconds: 2));
    await settle(tester);
    await shot(tester, 'receipt');
    await scrollTo(tester, find.byKey(const Key('track-order')));
    await shot(tester, 'receipt_payment');

    // ---------- ติดตามสถานะ ----------
    await tap(tester, find.byKey(const Key('track-order')));
    await shot(tester, 'status_pending');
    await tap(tester, find.byKey(const Key('simulate-next')));
    await shot(tester, 'status_cooking_notification');
    await wait(tester, const Duration(seconds: 4));
    await settle(tester);
    await tap(tester, find.byKey(const Key('simulate-next')));
    await shot(tester, 'status_ready_pickup_qr');
    await wait(tester, const Duration(seconds: 4));
    await settle(tester);
    await scrollTo(tester, find.byKey(const Key('simulate-next')));
    await tap(tester, find.byKey(const Key('simulate-next')));
    await wait(tester, const Duration(seconds: 4));
    await settle(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
    await settle(tester);
    await shot(tester, 'status_completed_points');
    await scrollTo(tester, find.text('ให้คะแนนร้าน'));
    await tap(tester, find.text('ให้คะแนนร้าน'));
    await shot(tester, 'rating_dialog');
    await tap(tester, find.text('ส่งคะแนน'));
    await tester.pageBack();
    await settle(tester);

    // ---------- ประวัติ / โปรไฟล์ ----------
    await tap(tester, find.text('ประวัติ'));
    await shot(tester, 'order_history');
    await tap(tester, find.text('โปรไฟล์'));
    await shot(tester, 'profile');
    await tap(tester, find.byKey(const Key('edit-profile')));
    await shot(tester, 'edit_profile');
    await tester.pageBack();
    await settle(tester);
    await logoutTo(tester, find.text('ออกจากระบบ'));

    // ---------- ร้านค้า ----------
    await login(tester, 'vendor');
    await shot(tester, 'vendor_dashboard');
    await tap(tester, find.text('ออเดอร์').last);
    await shot(tester, 'vendor_orders');
    await scrollTo(tester, find.byKey(const Key('accept-#A1042')));
    await shot(tester, 'vendor_order_pending');
    await tap(tester, find.byKey(const Key('accept-#A1042')));
    await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
    await settle(tester);
    await tap(tester, find.widgetWithText(ChoiceChip, 'อาหารพร้อมรับ'));
    await shot(tester, 'vendor_orders_ready');
    await tap(tester, find.text('สแกน QR รับอาหาร').first);
    await shot(tester, 'vendor_scan_pickup_qr');
    await tap(tester, find.text('ส่งมอบอาหาร'));

    await tap(tester, find.text('เมนู'));
    await tap(tester, find.byType(Switch).last);
    await shot(tester, 'vendor_manage_menu_stock');
    await tap(tester, find.byTooltip('เพิ่มเมนู'));
    await shot(tester, 'vendor_menu_form');
    await tester.pageBack();
    await settle(tester);

    await tap(tester, find.text('รายงาน'));
    await shot(tester, 'vendor_sales_daily');
    await tap(tester, find.text('รายเดือน'));
    await tester.drag(find.byType(ListView).last, const Offset(0, 2000));
    await settle(tester);
    await shot(tester, 'vendor_sales_monthly');
    await scrollTo(tester, find.text('การโอนเงินจาก PreFood'));
    await tester.drag(find.byType(ListView).last, const Offset(0, -2000));
    await settle(tester);
    await shot(tester, 'vendor_monthly_payout');

    await tap(tester, find.byTooltip('โปรไฟล์ร้าน'));
    await shot(tester, 'vendor_shop_profile');
    await logoutTo(tester, find.text('ออกจากระบบ'));

    // ---------- ผู้ดูแลระบบ ----------
    await login(tester, 'admin');
    await shot(tester, 'admin_dashboard');
    final menu = find.byTooltip('Open navigation menu');
    await tap(tester, menu);
    await shot(tester, 'admin_drawer');
    await tap(tester, find.text('จัดการร้านค้า'));
    await shot(tester, 'admin_manage_vendors');
    await tap(tester, menu);
    await tap(tester, find.text('จัดการผู้ใช้'));
    await shot(tester, 'admin_manage_users');
    await tap(tester, menu);
    await tap(tester, find.text('รายงานและสถิติ'));
    await shot(tester, 'admin_reports');
  });
}
