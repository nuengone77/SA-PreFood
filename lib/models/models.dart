import 'package:flutter/material.dart';

enum AppRole { customer, vendor, admin }

extension AppRoleLabel on AppRole {
  String get label => switch (this) {
    AppRole.customer => 'ลูกค้า',
    AppRole.vendor => 'ร้านค้า',
    AppRole.admin => 'ผู้ดูแลระบบ',
  };

  IconData get icon => switch (this) {
    AppRole.customer => Icons.person_outline_rounded,
    AppRole.vendor => Icons.storefront_outlined,
    AppRole.admin => Icons.admin_panel_settings_outlined,
  };
}

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.emoji,
    required this.color,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String emoji;
  final Color color;
  final bool isAvailable;

  FoodItem copyWith({bool? isAvailable}) => FoodItem(
    id: id,
    name: name,
    description: description,
    category: category,
    price: price,
    emoji: emoji,
    color: color,
    isAvailable: isAvailable ?? this.isAvailable,
  );
}

class Shop {
  const Shop({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.emoji,
    required this.color,
    required this.rating,
    required this.waitMinutes,
    required this.isOpen,
    required this.menu,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final String emoji;
  final Color color;
  final double rating;
  final int waitMinutes;
  final bool isOpen;
  final List<FoodItem> menu;
}

enum OrderStage { pending, cooking, ready, completed, rejected }

extension OrderStageInfo on OrderStage {
  String get label => switch (this) {
    OrderStage.pending => 'รอร้านรับออเดอร์',
    OrderStage.cooking => 'กำลังทำ',
    OrderStage.ready => 'พร้อมรับ',
    OrderStage.completed => 'รับอาหารแล้ว',
    OrderStage.rejected => 'ปฏิเสธแล้ว',
  };

  Color get color => switch (this) {
    OrderStage.pending => const Color(0xFFF2A23A),
    OrderStage.cooking => const Color(0xFF4D83C4),
    OrderStage.ready || OrderStage.completed => const Color(0xFF2F8064),
    OrderStage.rejected => const Color(0xFFC94B4B),
  };
}

class MockOrder {
  MockOrder({
    required this.id,
    required this.customerName,
    required this.shopName,
    required this.items,
    required this.total,
    required this.pickupTime,
    required this.stage,
  });

  final String id;
  final String customerName;
  final String shopName;
  final String items;
  final double total;
  final String pickupTime;
  OrderStage stage;
}
