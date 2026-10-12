import 'package:flutter/material.dart';

import '../../models/models.dart';
import 'cart_screen.dart';
import 'customer_home_screen.dart';
import 'order_history_screen.dart';
import 'payment_screen.dart';
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
  // index ของแท็บปัจจุบัน รายการในตะกร้า และร้านเจ้าของตะกร้า
  // หนึ่งออเดอร์สั่งได้จากร้านเดียว เพราะต้องจ่ายเงินเข้าบัญชีร้านนั้นโดยตรง
  int _index = 0;
  final List<CartLine> _cart = [];
  Shop? _cartShop;

  /// จำนวนสินค้ารวมทุกชิ้นสำหรับแสดง Badge ที่ไอคอนตะกร้า
  int get _cartCount => _cart.fold(0, (total, line) => total + line.quantity);

  /// เพิ่มรายการลงตะกร้า ถ้าเป็นเมนูและหมายเหตุเดียวกันจะรวมจำนวนให้
  /// ถ้าตะกร้ามีของจากร้านอื่นอยู่ จะถามก่อนล้างตะกร้า
  Future<bool> _addToCart(Shop shop, CartLine line) async {
    if (_cartShop != null && _cartShop!.id != shop.id && _cart.isNotEmpty) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('เริ่มตะกร้าใหม่?'),
          content: Text(
            'ตะกร้ามีเมนูจาก ${_cartShop!.name} อยู่ '
            'หนึ่งออเดอร์สั่งได้จากร้านเดียว ต้องการล้างตะกร้าเดิมหรือไม่',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ล้างตะกร้า'),
            ),
          ],
        ),
      );
      if (replace != true) return false;
      _cart.clear();
    }
    setState(() {
      _cartShop = shop;
      final existing = _cart
          .where((e) => e.item.id == line.item.id && e.note == line.note)
          .firstOrNull;
      if (existing != null) {
        existing.quantity += line.quantity;
      } else {
        _cart.add(line);
      }
    });
    return true;
  }

  /// เปิดหน้าร้านและส่ง callback เพิ่มสินค้าเข้าตะกร้ากลับมายัง shell
  void _openShop(Shop shop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShopMenuScreen(
          shopId: shop.id,
          cartCount: () => _cartCount,
          onAdd: (line) => _addToCart(shop, line),
          onViewCart: () {
            Navigator.pop(context);
            setState(() => _index = 2);
          },
        ),
      ),
    );
  }

  /// ไปหน้าชำระเงิน เมื่อชำระและแนบสลิปเรียบร้อยจึงล้างตะกร้า
  Future<void> _checkout(DateTime pickupAt) async {
    final placed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          shop: _cartShop!,
          lines: List.of(_cart),
          pickupAt: pickupAt,
        ),
      ),
    );
    if (placed == true) {
      setState(() {
        _cart.clear();
        _cartShop = null;
        _index = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // IndexedStack ช่วยรักษา state ของแต่ละหน้าไว้ขณะผู้ใช้สลับแท็บ
    final pages = [
      CustomerHomeScreen(onOpenShop: _openShop),
      const OrderHistoryScreen(),
      CartScreen(
        cart: _cart,
        shop: _cartShop,
        onAdd: (line) => setState(() => line.quantity++),
        onRemove: (line) => setState(() {
          if (line.quantity <= 1) {
            _cart.remove(line);
            if (_cart.isEmpty) _cartShop = null;
          } else {
            line.quantity--;
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
            key: const Key('nav-cart'),
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
