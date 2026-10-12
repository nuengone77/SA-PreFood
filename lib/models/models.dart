import 'package:flutter/material.dart';

/// ประเภทบัญชีที่ระบบรองรับ ใช้ตัดสินใจว่าจะเปิด flow ใดหลัง Login
enum AppRole { customer, vendor, admin }

/// เพิ่ม label ภาษาไทยและ icon ให้ค่าใน [AppRole]
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

/// โมเดลเมนูอาหารหนึ่งรายการ
/// เก็บข้อมูลที่จำเป็นต่อการแสดงผลและคำนวณราคาในตะกร้า
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

  /// สถานะวัตถุดิบ true = มีสินค้า, false = สินค้าหมด
  final bool isAvailable;

  /// ข้อความสถานะวัตถุดิบตามที่กำหนดในรายงาน (มีสินค้า/สินค้าหมด)
  String get stockLabel => isAvailable ? 'มีสินค้า' : 'สินค้าหมด';

  /// สร้างข้อมูลรายการใหม่โดยเปลี่ยนเฉพาะสถานะวัตถุดิบ
  /// ใช้ในหน้าจัดการเมนูของร้านค้า
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

/// โมเดลร้านค้า ประกอบด้วยข้อมูลหน้าร้าน ช่องทางรับเงิน และรายการอาหาร
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
    required this.location,
    required this.phone,
    required this.bankAccount,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final String emoji;
  final Color color;
  final double rating;
  final int waitMinutes;

  /// สถานะเปิด/ปิดรับออเดอร์
  final bool isOpen;
  final List<FoodItem> menu;
  final String location;
  final String phone;

  /// บัญชีธนาคารของร้าน ใช้รับเงินที่ PreFood โอนให้หลังหักค่าธรรมเนียม
  final String bankAccount;

  Shop copyWith({bool? isOpen, List<FoodItem>? menu}) => Shop(
    id: id,
    name: name,
    category: category,
    description: description,
    emoji: emoji,
    color: color,
    rating: rating,
    waitMinutes: waitMinutes,
    isOpen: isOpen ?? this.isOpen,
    menu: menu ?? this.menu,
    location: location,
    phone: phone,
    bankAccount: bankAccount,
  );
}

/// รายการหนึ่งบรรทัดในตะกร้า เก็บเมนู จำนวน และหมายเหตุพิเศษของรายการนั้น
class CartLine {
  CartLine({required this.item, this.quantity = 1, this.note = ''});

  final FoodItem item;
  int quantity;

  /// ตัวเลือกเพิ่มเติม/หมายเหตุพิเศษ เช่น ไม่เผ็ด แยกน้ำ
  final String note;

  double get subtotal => item.price * quantity;

  /// ข้อความสรุปรายการ เช่น "ข้าวกะเพราไก่ไข่ดาว x2 (ไม่เผ็ด)"
  String get summary =>
      '${item.name} x$quantity${note.isEmpty ? '' : ' ($note)'}';
}

/// สถานะทั้งหมดที่ออเดอร์สามารถอยู่ได้
enum OrderStage { pending, cooking, ready, completed, rejected }

/// แปลงสถานะออเดอร์ให้เป็นข้อความและสีสำหรับแสดงบน UI
/// ข้อความตรงกับสถานะที่กำหนดในรายงาน: รอยืนยัน/กำลังปรุงอาหาร/อาหารพร้อมรับ/สำเร็จ
extension OrderStageInfo on OrderStage {
  String get label => switch (this) {
    OrderStage.pending => 'รอยืนยัน',
    OrderStage.cooking => 'กำลังปรุงอาหาร',
    OrderStage.ready => 'อาหารพร้อมรับ',
    OrderStage.completed => 'สำเร็จ',
    OrderStage.rejected => 'ปฏิเสธแล้ว',
  };

  Color get color => switch (this) {
    OrderStage.pending => const Color(0xFFF2A23A),
    OrderStage.cooking => const Color(0xFF4D83C4),
    OrderStage.ready || OrderStage.completed => const Color(0xFF2F8064),
    OrderStage.rejected => const Color(0xFFC94B4B),
  };
}

/// ข้อมูลของแพลตฟอร์ม PreFood ซึ่งเป็นตัวกลางรับเงินจากลูกค้า
/// แล้วโอนยอดรวมรายเดือนให้ร้านค้าหลังหักค่าธรรมเนียม
abstract final class PlatformConfig {
  static const promptPayId = '0105569012345';
  static const bankAccount = 'กสิกรไทย 987-6-54321-0';
  static const accountName = 'บจก. พรีฟู้ด';

  /// ค่าธรรมเนียมที่เก็บจากร้านค้า คิดเป็นเปอร์เซ็นต์ของค่าอาหารแต่ละออเดอร์
  static const feePercent = 5;

  static double feeFor(double foodPrice) => foodPrice * feePercent / 100;

  /// PreFood โอนยอดรวมของเดือนให้ร้านค้าในวันที่นี้ของเดือนถัดไป
  static const payoutDay = 1;

  /// วันที่โอนยอดของเดือนที่ [month] อยู่
  static DateTime payoutDateFor(DateTime month) =>
      DateTime(month.year, month.month + 1, payoutDay);
}

/// ช่องทางการชำระเงิน ลูกค้าจ่ายเข้าบัญชี PreFood
enum PaymentMethod { promptPay, bankTransfer }

extension PaymentMethodInfo on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.promptPay => 'QR Code พร้อมเพย์',
    PaymentMethod.bankTransfer => 'โอนผ่านธนาคาร',
  };

  IconData get icon => switch (this) {
    PaymentMethod.promptPay => Icons.qr_code_2_rounded,
    PaymentMethod.bankTransfer => Icons.account_balance_outlined,
  };
}

/// สถานะการชำระเงินของลูกค้า
/// ระบบตรวจยอดโอนเข้าบัญชี PreFood อัตโนมัติ ลูกค้าไม่ต้องแนบสลิป
enum PaymentStatus { verifying, verified, refunded }

extension PaymentStatusInfo on PaymentStatus {
  String get label => switch (this) {
    PaymentStatus.verifying => 'รอตรวจสอบ',
    PaymentStatus.verified => 'ยืนยันแล้ว',
    PaymentStatus.refunded => 'คืนเงินแล้ว',
  };

  Color get color => switch (this) {
    PaymentStatus.verifying => const Color(0xFFF2A23A),
    PaymentStatus.verified => const Color(0xFF2F8064),
    PaymentStatus.refunded => const Color(0xFFC94B4B),
  };
}

/// โมเดลออเดอร์ ใช้ร่วมกันในหน้าลูกค้า ร้านค้า และประวัติ
/// ฟิลด์ที่เปลี่ยนได้ ([stage], [paymentStatus], [rating]) ถูกอัปเดตผ่าน AppStore
class MockOrder {
  MockOrder({
    required this.id,
    required this.queueNumber,
    required this.customerName,
    required this.shopId,
    required this.shopName,
    required this.lines,
    required this.orderedAt,
    required this.pickupAt,
    required this.paymentMethod,
    required this.stage,
    this.paymentStatus = PaymentStatus.verifying,
    this.isMine = false,
    this.pointsUsed = 0,
    this.pointsEarned = 0,
  });

  final String id;

  /// หมายเลขคิวของร้าน แสดงบนใบเสร็จและใช้เรียกลูกค้ามารับอาหาร
  final int queueNumber;
  final String customerName;
  final String shopId;
  final String shopName;
  final List<CartLine> lines;

  /// วันเวลาที่ทำรายการ
  final DateTime orderedAt;

  /// วันเวลาที่นัดรับอาหาร
  final DateTime pickupAt;
  final PaymentMethod paymentMethod;
  OrderStage stage;
  PaymentStatus paymentStatus;

  /// คะแนนที่ลูกค้าให้หลังรับอาหาร (1-5) ยังไม่ให้คะแนนเป็น null
  int? rating;

  /// true เมื่อเป็นออเดอร์ของลูกค้าที่ล็อกอินอยู่ ใช้แสดงในหน้าประวัติ
  final bool isMine;

  /// แต้มสะสมที่ใช้เป็นส่วนลดในออเดอร์นี้ (1 แต้ม = 1 บาท)
  final int pointsUsed;

  /// แต้มที่ได้รับจากออเดอร์นี้ ได้เมื่อรับอาหารสำเร็จ (0 = ยังไม่ได้รับ)
  int pointsEarned;

  /// ค่าอาหารก่อนหักส่วนลด
  double get subtotal => lines.fold(0, (sum, line) => sum + line.subtotal);

  /// ส่วนลดจากแต้มสะสม
  double get discount => pointsUsed.toDouble();

  /// ยอดที่ลูกค้าโอนเข้า PreFood หลังหักส่วนลดจากแต้ม
  double get total => subtotal - discount;

  /// ค่าธรรมเนียมที่ PreFood หักจากร้าน คิดจากค่าอาหารเต็ม
  double get platformFee => PlatformConfig.feeFor(subtotal);

  /// เงินที่ร้านได้รับจาก PreFood ส่วนลดจากแต้มเป็นภาระของแพลตฟอร์ม
  /// ร้านจึงได้ค่าอาหารเต็มหักค่าธรรมเนียมเสมอ
  double get shopPayout => subtotal - platformFee;

  String get items => lines.map((line) => line.summary).join(', ');
  String get queueLabel => 'Q${queueNumber.toString().padLeft(3, '0')}';
}

const _thaiMonths = [
  'ม.ค.',
  'ก.พ.',
  'มี.ค.',
  'เม.ย.',
  'พ.ค.',
  'มิ.ย.',
  'ก.ค.',
  'ส.ค.',
  'ก.ย.',
  'ต.ค.',
  'พ.ย.',
  'ธ.ค.',
];

/// แปลงเวลาเป็นรูปแบบ HH:mm
String formatTime(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

/// แปลงวันที่เป็นรูปแบบไทยแบบย่อ เช่น "12 ต.ค."
String formatThaiDate(DateTime date) =>
    '${date.day} ${_thaiMonths[date.month - 1]}';

/// แปลงวันเวลาเป็นรูปแบบ "12 ต.ค. • 12:15"
String formatDateTime(DateTime time) =>
    '${formatThaiDate(time)} • ${formatTime(time)}';

/// แปลงเป็นเดือนและปี พ.ศ. แบบย่อ เช่น "ต.ค. 2569"
String formatThaiMonthYear(DateTime date) =>
    '${_thaiMonths[date.month - 1]} ${date.year + 543}';

/// แปลงจำนวนเงินเป็นรูปแบบ "฿18,420"
String formatBaht(num value) =>
    '฿${value.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
