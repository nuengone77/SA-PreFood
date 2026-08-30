import 'package:flutter/material.dart';

import '../../models/models.dart';
import 'cart_screen.dart';
import 'customer_home_screen.dart';
import 'order_history_screen.dart';
import 'order_status_screen.dart';
import 'profile_screen.dart';
import 'shop_menu_screen.dart';

/// โครงหน้าหลักของลูกค้า รับผิดชอบ Bottom Navigation และตะกร้าส่วนกลาง
/// การเก็บตะกร้าไว้ที่ shell ทำให้ข้อมูลยังอยู่เมื่อสลับแท็บ
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  // index ของแท็บปัจจุบัน และ map ที่จับคู่เมนูกับจำนวนในตะกร้า
  int _index = 0;
  final Map<FoodItem, int> _cart = {};

  /// จำนวนสินค้ารวมทุกชิ้นสำหรับแสดง Badge ที่ไอคอนตะกร้า
  int get _cartCount => _cart.values.fold(0, (total, value) => total + value);

  /// เปิดหน้าร้านและส่ง callback เพิ่มสินค้าเข้าตะกร้ากลับมายัง shell
  void _openShop(Shop shop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShopMenuScreen(
          shop: shop,
          cartCount: _cartCount,
          onAdd: (item) {
            setState(() => _cart[item] = (_cart[item] ?? 0) + 1);
          },
          onViewCart: () {
            Navigator.pop(context);
            setState(() => _index = 2);
          },
        ),
      ),
    );
  }

  /// รวมรายการและยอดเงินจากตะกร้าเป็นออเดอร์จำลอง
  /// จากนั้นล้างตะกร้าและเปิดหน้าติดตามสถานะ
  void _checkout(String pickupTime) {
    final items = _cart.entries
        .map((e) => '${e.key.name} x${e.value}')
        .join(', ');
    final total = _cart.entries.fold<double>(
      0,
      (sum, e) => sum + e.key.price * e.value,
    );
    final order = MockOrder(
      id: '#A1043',
      customerName: 'คุณ',
      shopName: 'ครัวป้าแดง',
      items: items,
      total: total,
      pickupTime: pickupTime,
      stage: OrderStage.pending,
    );
    setState(() => _cart.clear());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderStatusScreen(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // IndexedStack ช่วยรักษา state ของแต่ละหน้าไว้ขณะผู้ใช้สลับแท็บ
    final pages = [
      CustomerHomeScreen(onOpenShop: _openShop),
      const OrderHistoryScreen(),
      CartScreen(
        cart: _cart,
        onAdd: (item) => setState(() => _cart[item] = (_cart[item] ?? 0) + 1),
        onRemove: (item) => setState(() {
          final quantity = _cart[item] ?? 0;
          if (quantity <= 1) {
            _cart.remove(item);
          } else {
            _cart[item] = quantity - 1;
          }
        }),
        onBrowse: () => setState(() => _index = 0),
        onCheckout: _checkout,
      ),
      const CustomerProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'หน้าแรก',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'ประวัติ',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_bag_rounded),
            ),
            label: 'ตะกร้า',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}
