import 'package:flutter/material.dart';

import '../../app_store.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import 'awaiting_payment_screen.dart';
import 'receipt_screen.dart';

/// หน้าชำระเงิน สรุปยอด ใช้แต้มสะสม และเลือกช่องทางชำระ (รายงานข้อ 2.2.3, 2.3.4)
/// ลูกค้าจ่ายเข้าบัญชี PreFood แล้ว PreFood โอนยอดรวมรายเดือนให้ร้านค้า
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.shop,
    required this.lines,
    required this.pickupAt,
  });
  final Shop shop;
  final List<CartLine> lines;
  final DateTime pickupAt;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.promptPay;

  /// เลือกใช้แต้มสะสมเป็นส่วนลดหรือไม่ (รายงานข้อ 3.3.1)
  bool _usePoints = false;

  double get _subtotal =>
      widget.lines.fold(0, (sum, line) => sum + line.subtotal);

  /// แต้มที่จะใช้ในออเดอร์นี้ ใช้ได้สูงสุดตามกติกาใน [AppStore.redeemableFor]
  int get _pointsUsed => _usePoints ? appStore.redeemableFor(_subtotal) : 0;

  /// ยอดที่ต้องชำระหลังหักส่วนลด
  double get _total => _subtotal - _pointsUsed;

  /// เปิดหน้าสแกนจ่าย เมื่อระบบตรวจพบยอดโอนแล้วจะได้ออเดอร์กลับมา
  Future<void> _pay() async {
    final order = await Navigator.push<MockOrder>(
      context,
      MaterialPageRoute(
        builder: (_) => AwaitingPaymentScreen(
          shop: widget.shop,
          lines: widget.lines,
          pickupAt: widget.pickupAt,
          method: _method,
          pointsUsed: _pointsUsed,
        ),
      ),
    );
    if (order == null || !mounted) return;
    // ส่งผล true กลับไปให้ CustomerShell ล้างตะกร้า
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ReceiptScreen(order: order)),
      result: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ชำระเงิน',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'นัดรับ ${formatDateTime(widget.pickupAt)} • ${shop.location}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  ...widget.lines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(line.summary)),
                          Text('฿${line.subtotal.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                  ),
                  if (_pointsUsed > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'ส่วนลดจากแต้มสะสม ($_pointsUsed แต้ม)',
                              style: const TextStyle(color: AppColors.green),
                            ),
                          ),
                          Text(
                            '-฿$_pointsUsed',
                            style: const TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text(
                        'ยอดที่ต้องชำระ',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        '฿${_total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.orangeDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _PointsCard(
            balance: appStore.points,
            redeemable: appStore.redeemableFor(_subtotal),
            willEarn: AppStore.pointsFor(_total),
            value: _usePoints,
            onChanged: (value) => setState(() => _usePoints = value),
          ),
          const SizedBox(height: 20),
          Text(
            'ช่องทางการชำระเงิน',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SegmentedButton<PaymentMethod>(
            segments: PaymentMethod.values
                .map(
                  (method) => ButtonSegment(
                    value: method,
                    icon: Icon(method.icon),
                    label: Text(method.label),
                  ),
                )
                .toList(),
            selected: {_method},
            onSelectionChanged: (value) =>
                setState(() => _method = value.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 10),
          const Text(
            'ชำระเข้าบัญชี PreFood ระบบตรวจสอบยอดโอนให้อัตโนมัติ ไม่ต้องแนบสลิป',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            key: const Key('pay-now'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: _pay,
            icon: Icon(_method.icon),
            label: Text('ชำระเงิน ฿${_total.toStringAsFixed(0)}'),
          ),
        ],
      ),
    );
  }
}

/// การ์ดแต้มสะสม แสดงแต้มคงเหลือ สวิตช์ใช้แต้ม และแต้มที่จะได้รับจากออเดอร์นี้
class _PointsCard extends StatelessWidget {
  const _PointsCard({
    required this.balance,
    required this.redeemable,
    required this.willEarn,
    required this.value,
    required this.onChanged,
  });
  final int balance;
  final int redeemable;
  final int willEarn;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 10, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFFFB33A)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ใช้แต้มสะสมเป็นส่วนลด',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      redeemable > 0
                          ? 'มี $balance แต้ม • ใช้ได้ $redeemable แต้ม (ลด ฿$redeemable)'
                          : 'มี $balance แต้ม • ยังไม่มีแต้มให้ใช้',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                key: const Key('use-points'),
                value: value,
                onChanged: redeemable > 0 ? onChanged : null,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'รับอาหารสำเร็จจะได้รับ $willEarn แต้ม '
            '(ทุก ฿${AppStore.bahtPerPoint} = 1 แต้ม, '
            'ใช้ลดได้ไม่เกิน ${AppStore.maxDiscountPercent}% ของค่าอาหาร)',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
