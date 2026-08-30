import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../auth/splash_screen.dart';
import 'admin_dashboard_screen.dart';
import 'manage_users_screen.dart';
import 'manage_vendors_screen.dart';
import 'reports_screen.dart';

/// โครงหน้าหลักของผู้ดูแลระบบ ใช้ Navigation Drawer แทน Bottom Navigation
/// เพื่อรองรับเมนูจัดการหลายหมวดหมู่
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  // index ใช้เลือกทั้งหัวข้อ AppBar, เนื้อหาหน้า และรายการใน Drawer
  int _index = 0;
  static const titles = [
    'ภาพรวมระบบ',
    'จัดการร้านค้า',
    'จัดการผู้ใช้',
    'รายงานและสถิติ',
  ];

  @override
  Widget build(BuildContext context) {
    const pages = [
      AdminDashboardScreen(),
      ManageVendorsScreen(),
      ManageUsersScreen(),
      ReportsScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_index],
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: Badge(
              smallSize: 8,
              child: Icon(Icons.notifications_none_rounded),
            ),
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
          Navigator.pop(context);
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
            child: Row(
              children: [
                const BrandMark(size: 52),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'PreFood',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Admin Console',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: Text('ภาพรวมระบบ'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: Text('จัดการร้านค้า'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: Text('จัดการผู้ใช้'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: Text('รายงานและสถิติ'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Divider(),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 28),
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text(
              'ออกจากระบบ',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SplashScreen()),
              (_) => false,
            ),
          ),
        ],
      ),
      // รักษา state ของหน้าจัดการแต่ละหน้าไว้เมื่อสลับเมนูใน Drawer
      body: IndexedStack(index: _index, children: pages),
    );
  }
}
