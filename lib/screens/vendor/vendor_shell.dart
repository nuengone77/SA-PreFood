import 'package:flutter/material.dart';

import '../../app_store.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'manage_menu_screen.dart';
import 'sales_report_screen.dart';
import 'shop_profile_screen.dart';
import 'vendor_orders_screen.dart';

/// โครงหน้าหลักของร้านค้า จัดการ AppBar, Bottom Navigation และหน้าทั้ง 4 แท็บ
class VendorShell extends StatefulWidget {
  const VendorShell({super.key});

  @override
  State<VendorShell> createState() => _VendorShellState();
}

class _VendorShellState extends State<VendorShell> {
  // index ของแท็บร้านค้าที่กำลังแสดง
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    // ส่ง callback ให้ Dashboard สามารถพาไปแท็บออเดอร์ได้โดยตรง
    final pages = [
      VendorDashboardScreen(onViewOrders: () => setState(() => _index = 1)),
      const VendorOrdersScreen(),
      const ManageMenuScreen(),
      const SalesReportScreen(),
    ];
    // จำนวนออเดอร์ที่รอยืนยัน ใช้แสดง Badge บนแท็บออเดอร์
    final pending = appStore.vendorOrders
        .where((order) => order.stage == OrderStage.pending)
        .length;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ครัวป้าแดง',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                Text(
                  'โหมดร้านค้า',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'โปรไฟล์ร้าน',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopProfileScreen()),
            ),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'แดชบอร์ด',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.receipt_long_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.receipt_long_rounded),
            ),
            label: 'ออเดอร์',
          ),
          const NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'เมนู',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'รายงาน',
          ),
        ],
      ),
    );
  }
}
