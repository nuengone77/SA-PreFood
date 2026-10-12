import 'package:flutter/material.dart';

import 'models/models.dart';

/// ข้อมูลร้านค้าและเมนูตัวอย่างที่ใช้ในหน้าค้นหาร้านและจัดการเมนู
/// ในระบบจริงข้อมูลชุดนี้จะถูกแทนที่ด้วยข้อมูลจาก API หรือฐานข้อมูล
const mockShops = <Shop>[
  Shop(
    id: 's1',
    location: 'โรงอาหารกลาง ล็อก A03',
    phone: '089-123-4567',
    bankAccount: 'กสิกรไทย 123-4-56789-0',
    name: 'ครัวป้าแดง',
    category: 'อาหารตามสั่ง',
    description: 'อิ่มอร่อย รสจัดจ้าน ทำสดทุกจาน',
    emoji: '🍳',
    color: Color(0xFFFFDCCB),
    rating: 4.8,
    waitMinutes: 15,
    isOpen: true,
    menu: [
      FoodItem(
        id: 'f1',
        name: 'ข้าวกะเพราไก่ไข่ดาว',
        description: 'ไก่สับผัดกะเพราหอมๆ พร้อมไข่ดาว',
        category: 'จานหลัก',
        price: 55,
        emoji: '🍛',
        color: Color(0xFFFFD4A8),
      ),
      FoodItem(
        id: 'f2',
        name: 'ข้าวหมูกระเทียม',
        description: 'หมูนุ่มผัดกระเทียมพริกไทย',
        category: 'จานหลัก',
        price: 50,
        emoji: '🍚',
        color: Color(0xFFFFE3B8),
      ),
      FoodItem(
        id: 'f3',
        name: 'ผัดซีอิ๊วหมู',
        description: 'เส้นใหญ่ผัดหอมกระทะ',
        category: 'เส้น',
        price: 50,
        emoji: '🍜',
        color: Color(0xFFE7D4B5),
      ),
    ],
  ),
  Shop(
    id: 's2',
    location: 'โรงอาหารกลาง ล็อก A05',
    phone: '081-234-5678',
    bankAccount: 'ไทยพาณิชย์ 234-5-67890-1',
    name: 'บ้านเส้น',
    category: 'ก๋วยเตี๋ยว',
    description: 'น้ำซุปเคี่ยวนาน ลูกชิ้นทำเอง',
    emoji: '🍜',
    color: Color(0xFFD9EEDB),
    rating: 4.7,
    waitMinutes: 10,
    isOpen: true,
    menu: [
      FoodItem(
        id: 'f4',
        name: 'ก๋วยเตี๋ยวต้มยำ',
        description: 'ต้มยำมะนาวสด ครบรส',
        category: 'เส้น',
        price: 50,
        emoji: '🥢',
        color: Color(0xFFD1E8D4),
      ),
      FoodItem(
        id: 'f5',
        name: 'บะหมี่หมูแดง',
        description: 'บะหมี่ไข่เส้นนุ่ม หมูแดงฉ่ำ',
        category: 'เส้น',
        price: 55,
        emoji: '🍜',
        color: Color(0xFFFFD1C7),
      ),
    ],
  ),
  Shop(
    id: 's3',
    location: 'โรงอาหารกลาง ล็อก B01',
    phone: '082-345-6789',
    bankAccount: 'กรุงเทพ 345-6-78901-2',
    name: 'หวานใจ',
    category: 'ของหวาน',
    description: 'เติมความสดชื่นระหว่างวัน',
    emoji: '🍧',
    color: Color(0xFFFFDCEA),
    rating: 4.9,
    waitMinutes: 8,
    isOpen: true,
    menu: [
      FoodItem(
        id: 'f6',
        name: 'บิงซูนมสด',
        description: 'เกล็ดหิมะนมสด ท็อปปิ้งผลไม้',
        category: 'ของหวาน',
        price: 69,
        emoji: '🍧',
        color: Color(0xFFFFDDE9),
      ),
      FoodItem(
        id: 'f7',
        name: 'เฉาก๊วยนมสด',
        description: 'เฉาก๊วยหนึบกับนมสดหอม',
        category: 'ของหวาน',
        price: 35,
        emoji: '🥛',
        color: Color(0xFFD8CEC6),
      ),
    ],
  ),
  Shop(
    id: 's4',
    location: 'โรงอาหารกลาง ล็อก B04',
    phone: '083-456-7890',
    bankAccount: 'กรุงไทย 456-7-89012-3',
    name: 'Daily Brew',
    category: 'เครื่องดื่ม',
    description: 'กาแฟและเครื่องดื่มสดชื่น',
    emoji: '🥤',
    color: Color(0xFFD7E7F3),
    rating: 4.6,
    waitMinutes: 5,
    isOpen: false,
    menu: [
      FoodItem(
        id: 'f8',
        name: 'ชาไทย',
        description: 'ชาเข้ม หวานมันกำลังดี',
        category: 'เครื่องดื่ม',
        price: 35,
        emoji: '🧋',
        color: Color(0xFFFFD09D),
      ),
      FoodItem(
        id: 'f9',
        name: 'อเมริกาโน่เย็น',
        description: 'เมล็ดกาแฟคั่วกลาง',
        category: 'เครื่องดื่ม',
        price: 45,
        emoji: '☕',
        color: Color(0xFFDDC9B7),
      ),
    ],
  ),
];

/// สร้างออเดอร์ตั้งต้นของระบบ ทั้งออเดอร์ที่เข้าร้านครัวป้าแดงวันนี้
/// และประวัติการสั่งซื้อย้อนหลังของลูกค้าที่ล็อกอินอยู่
List<MockOrder> buildSeedOrders() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final padaeng = mockShops[0];
  final banSen = mockShops[1];
  final wanJai = mockShops[2];
  return [
    MockOrder(
      id: '#A1042',
      queueNumber: 42,
      customerName: 'นนท์',
      shopId: padaeng.id,
      shopName: padaeng.name,
      lines: [CartLine(item: padaeng.menu[0], note: 'ไม่เผ็ด')],
      orderedAt: today.add(const Duration(hours: 11, minutes: 32)),
      pickupAt: today.add(const Duration(hours: 12, minutes: 15)),
      paymentMethod: PaymentMethod.promptPay,
      stage: OrderStage.pending,
      paymentStatus: PaymentStatus.verified,
    ),
    MockOrder(
      id: '#A1041',
      queueNumber: 41,
      customerName: 'มินตรา',
      shopId: padaeng.id,
      shopName: padaeng.name,
      lines: [CartLine(item: padaeng.menu[1], quantity: 2)],
      orderedAt: today.add(const Duration(hours: 11, minutes: 20)),
      pickupAt: today.add(const Duration(hours: 12, minutes: 10)),
      paymentMethod: PaymentMethod.bankTransfer,
      stage: OrderStage.cooking,
      paymentStatus: PaymentStatus.verified,
    ),
    MockOrder(
      id: '#A1040',
      queueNumber: 40,
      customerName: 'ภัทร',
      shopId: padaeng.id,
      shopName: padaeng.name,
      lines: [CartLine(item: padaeng.menu[2])],
      orderedAt: today.add(const Duration(hours: 11, minutes: 5)),
      pickupAt: today.add(const Duration(hours: 12)),
      paymentMethod: PaymentMethod.promptPay,
      stage: OrderStage.ready,
      paymentStatus: PaymentStatus.verified,
    ),
    MockOrder(
      id: '#A0998',
      queueNumber: 18,
      customerName: 'ธนกร',
      shopId: banSen.id,
      shopName: banSen.name,
      lines: [CartLine(item: banSen.menu[0], note: 'แยกน้ำ')],
      pointsEarned: 5,
      orderedAt: today.subtract(const Duration(days: 2, hours: 13)),
      pickupAt: today.subtract(const Duration(days: 2, hours: 12, minutes: 20)),
      paymentMethod: PaymentMethod.promptPay,
      stage: OrderStage.completed,
      paymentStatus: PaymentStatus.verified,
      isMine: true,
    ),
    MockOrder(
      id: '#A0971',
      queueNumber: 7,
      customerName: 'ธนกร',
      shopId: wanJai.id,
      shopName: wanJai.name,
      lines: [CartLine(item: wanJai.menu[1], quantity: 2)],
      pointsEarned: 7,
      orderedAt: today.subtract(const Duration(days: 5, hours: 9)),
      pickupAt: today.subtract(const Duration(days: 5, hours: 8, minutes: 30)),
      paymentMethod: PaymentMethod.bankTransfer,
      stage: OrderStage.completed,
      paymentStatus: PaymentStatus.verified,
      isMine: true,
    )..rating = 5,
  ];
}

/// ช่วงเวลาของรายงานยอดขายร้านค้า
enum SalesPeriod { daily, weekly, monthly }

extension SalesPeriodLabel on SalesPeriod {
  String get label => switch (this) {
    SalesPeriod.daily => 'รายวัน',
    SalesPeriod.weekly => 'รายสัปดาห์',
    SalesPeriod.monthly => 'รายเดือน',
  };
}

/// สรุปยอดขายของร้านในหนึ่งช่วงเวลา
class SalesSummary {
  const SalesSummary({
    required this.orders,
    required this.revenue,
    required this.bestSellers,
  });
  final int orders;
  final double revenue;

  /// เมนูขายดี เรียงจากจำนวนจานที่ขายได้มากไปน้อย
  final List<(String name, String emoji, int sold)> bestSellers;
}

/// ข้อมูลรายงานยอดขายตัวอย่างของร้านครัวป้าแดง
const vendorSalesReport = <SalesPeriod, SalesSummary>{
  SalesPeriod.daily: SalesSummary(
    orders: 20,
    revenue: 1245,
    bestSellers: [
      ('ข้าวกะเพราไก่ไข่ดาว', '🍛', 11),
      ('ข้าวหมูกระเทียม', '🍚', 8),
      ('ผัดซีอิ๊วหมู', '🍜', 5),
    ],
  ),
  SalesPeriod.weekly: SalesSummary(
    orders: 84,
    revenue: 4690,
    bestSellers: [
      ('ข้าวกะเพราไก่ไข่ดาว', '🍛', 41),
      ('ข้าวหมูกระเทียม', '🍚', 30),
      ('ผัดซีอิ๊วหมู', '🍜', 21),
    ],
  ),
  SalesPeriod.monthly: SalesSummary(
    orders: 326,
    revenue: 18420,
    bestSellers: [
      ('ข้าวกะเพราไก่ไข่ดาว', '🍛', 152),
      ('ข้าวหมูกระเทียม', '🍚', 118),
      ('ผัดซีอิ๊วหมู', '🍜', 87),
    ],
  ),
};

/// ยอดสุทธิที่ PreFood โอนให้ร้านครัวป้าแดงในเดือนก่อน ๆ (หลังหักค่าธรรมเนียม)
/// เรียงจากเดือนล่าสุด ใช้แสดงประวัติการโอนรายเดือน
const vendorPastPayouts = [15930.0, 14202.0, 16488.0];
