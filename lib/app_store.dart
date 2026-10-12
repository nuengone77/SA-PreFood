import 'package:flutter/foundation.dart';

import 'mock_data.dart';
import 'models/models.dart';

/// ข้อมูลส่วนตัวของผู้ใช้ตามที่รายงานกำหนด (ข้อ 2.2.1)
class UserProfile {
  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.studentStaffId,
    required this.phone,
    required this.username,
  });

  final String firstName;
  final String lastName;
  final String studentStaffId;
  final String phone;
  final String username;

  String get fullName => '$firstName $lastName';
}

/// state กลางของ prototype แทน backend
/// ทุกหน้าที่ฟัง [appStore] จะเห็นข้อมูลชุดเดียวกัน เช่น ออเดอร์ที่ลูกค้าสั่ง
/// จะไปปรากฏที่หน้าร้านค้า และสถานะที่ร้านอัปเดตจะกลับไปแสดงที่หน้าลูกค้า
class AppStore extends ChangeNotifier {
  AppStore() {
    reset();
  }

  /// ร้านที่ผู้ใช้โหมดร้านค้าเป็นเจ้าของ
  static const vendorShopId = 's1';

  late List<Shop> _shops;
  late List<MockOrder> _orders;
  late UserProfile profile;
  late int _nextOrderNumber;

  /// แต้มสะสมคงเหลือของลูกค้า (รายงานข้อ 3.3.1)
  late int points;

  // กติกาแต้มสะสม แก้ค่าที่นี่ที่เดียวหากต้องการเปลี่ยนเงื่อนไข
  /// ยอดชำระทุก ๆ กี่บาทจะได้ 1 แต้ม
  static const bahtPerPoint = 10;

  /// ใช้แต้มลดได้ไม่เกินกี่เปอร์เซ็นต์ของค่าอาหาร
  static const maxDiscountPercent = 50;

  /// แต้มที่จะได้รับจากยอดชำระ
  static int pointsFor(double paid) => paid ~/ bahtPerPoint;

  /// แต้มสูงสุดที่ใช้ได้กับค่าอาหารนี้ (1 แต้ม = 1 บาท)
  int redeemableFor(double subtotal) {
    final cap = (subtotal * maxDiscountPercent / 100).floor();
    return points < cap ? points : cap;
  }

  List<Shop> get shops => List.unmodifiable(_shops);
  List<MockOrder> get orders => List.unmodifiable(_orders);

  Shop shopById(String id) => _shops.firstWhere((shop) => shop.id == id);
  Shop get vendorShop => shopById(vendorShopId);

  /// ออเดอร์ของร้านค้า เรียงตามเวลานัดรับเพื่อจัดคิวการทำอาหาร
  List<MockOrder> get vendorOrders =>
      _orders.where((order) => order.shopId == vendorShopId).toList()
        ..sort((a, b) => a.pickupAt.compareTo(b.pickupAt));

  /// ประวัติการสั่งซื้อของลูกค้า เรียงจากล่าสุดไปเก่าสุด
  List<MockOrder> get myOrders =>
      _orders.where((order) => order.isMine).toList()
        ..sort((a, b) => b.orderedAt.compareTo(a.orderedAt));

  /// คืนค่าข้อมูลทั้งหมดเป็นค่าเริ่มต้น ใช้ตอนเริ่มแอปและใน test
  void reset() {
    _shops = [...mockShops];
    _orders = buildSeedOrders();
    _nextOrderNumber = 1043;
    // แต้มตั้งต้นเท่ากับแต้มที่ได้จากประวัติการสั่งซื้อ (5 + 7)
    points = 12;
    profile = const UserProfile(
      firstName: 'ธนกร',
      lastName: 'ใจดี',
      studentStaffId: '67312345',
      phone: '081-111-2233',
      username: 'thanakorn',
    );
    notifyListeners();
  }

  void updateProfile(UserProfile value) {
    profile = value;
    notifyListeners();
  }

  /// เวลาที่จำลองว่าระบบตรวจพบยอดโอนเข้าบัญชี PreFood
  /// (prototype ไม่มี backend จริง จึงจำลองว่าลูกค้าโอนสำเร็จหลังเวลานี้)
  static const paymentDetectDelay = Duration(seconds: 3);

  /// สร้างออเดอร์หลังระบบตรวจพบยอดโอนแล้ว และออกหมายเลขคิวของร้าน
  MockOrder placeOrder({
    required Shop shop,
    required List<CartLine> lines,
    required DateTime pickupAt,
    required PaymentMethod paymentMethod,
    int pointsUsed = 0,
  }) {
    assert(pointsUsed <= points, 'ใช้แต้มเกินกว่าที่มี');
    final queue =
        _orders
            .where((order) => order.shopId == shop.id)
            .fold<int>(
              0,
              (max, o) => o.queueNumber > max ? o.queueNumber : max,
            ) +
        1;
    final order = MockOrder(
      id: '#A${_nextOrderNumber++}',
      queueNumber: queue,
      customerName: profile.firstName,
      shopId: shop.id,
      shopName: shop.name,
      lines: [
        for (final line in lines)
          CartLine(item: line.item, quantity: line.quantity, note: line.note),
      ],
      orderedAt: DateTime.now(),
      pickupAt: pickupAt,
      paymentMethod: paymentMethod,
      stage: OrderStage.pending,
      paymentStatus: PaymentStatus.verified,
      isMine: true,
      pointsUsed: pointsUsed,
    );
    points -= pointsUsed;
    _orders.add(order);
    notifyListeners();
    return order;
  }

  /// ร้านรับออเดอร์ ทำได้เมื่อ PreFood ยืนยันการชำระเงินแล้ว
  void acceptOrder(MockOrder order) {
    assert(order.paymentStatus == PaymentStatus.verified);
    order.stage = OrderStage.cooking;
    notifyListeners();
  }

  /// ร้านปฏิเสธออเดอร์ PreFood คืนเงินและคืนแต้มที่ใช้ไปให้ลูกค้า
  void rejectOrder(MockOrder order) {
    order
      ..paymentStatus = PaymentStatus.refunded
      ..stage = OrderStage.rejected;
    if (order.isMine) points += order.pointsUsed;
    notifyListeners();
  }

  /// เมื่อออเดอร์สำเร็จ ลูกค้าได้รับแต้มตามยอดที่ชำระจริง
  void updateStage(MockOrder order, OrderStage stage) {
    order.stage = stage;
    if (stage == OrderStage.completed &&
        order.isMine &&
        order.pointsEarned == 0) {
      order.pointsEarned = pointsFor(order.total);
      points += order.pointsEarned;
    }
    notifyListeners();
  }

  void rateOrder(MockOrder order, int rating) {
    order.rating = rating;
    notifyListeners();
  }

  void setShopOpen(String shopId, bool isOpen) {
    _replaceShop(shopById(shopId).copyWith(isOpen: isOpen));
  }

  /// เพิ่มเมนูใหม่ หรือแทนที่เมนูเดิมที่มี id เดียวกัน
  void saveMenuItem(String shopId, FoodItem item) {
    final shop = shopById(shopId);
    final menu = [...shop.menu];
    final index = menu.indexWhere((e) => e.id == item.id);
    if (index == -1) {
      menu.add(item);
    } else {
      menu[index] = item;
    }
    _replaceShop(shop.copyWith(menu: menu));
  }

  void deleteMenuItem(String shopId, FoodItem item) {
    final shop = shopById(shopId);
    _replaceShop(
      shop.copyWith(menu: shop.menu.where((e) => e.id != item.id).toList()),
    );
  }

  void _replaceShop(Shop shop) {
    _shops[_shops.indexWhere((e) => e.id == shop.id)] = shop;
    notifyListeners();
  }
}

/// instance เดียวที่ทุกหน้าจอใช้ร่วมกัน
final appStore = AppStore();
