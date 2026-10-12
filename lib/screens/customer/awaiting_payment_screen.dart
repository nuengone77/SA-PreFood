import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_store.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

/// หน้าสแกนจ่าย แสดง QR พร้อมเพย์หรือเลขบัญชีของ PreFood พร้อมยอดที่ต้องโอน
/// ระบบตรวจยอดโอนเข้าบัญชีให้อัตโนมัติ ลูกค้าไม่ต้องแนบสลิป
/// prototype ไม่มี backend จริง จึงจำลองว่าตรวจพบยอดโอนหลัง [AppStore.paymentDetectDelay]
/// แล้ว pop ออเดอร์ที่สร้างเสร็จกลับไปให้ [PaymentScreen]
class AwaitingPaymentScreen extends StatefulWidget {
  const AwaitingPaymentScreen({
    super.key,
    required this.shop,
    required this.lines,
    required this.pickupAt,
    required this.method,
    required this.pointsUsed,
  });
  final Shop shop;
  final List<CartLine> lines;
  final DateTime pickupAt;
  final PaymentMethod method;
  final int pointsUsed;

  @override
  State<AwaitingPaymentScreen> createState() => _AwaitingPaymentScreenState();
}

class _AwaitingPaymentScreenState extends State<AwaitingPaymentScreen> {
  /// QR มีอายุ 15 นาที
  static const _expiry = Duration(minutes: 15);

  PaymentStatus _status = PaymentStatus.verifying;
  Duration _remaining = _expiry;
  Timer? _countdown;
  Timer? _detect;

  double get _amount =>
      widget.lines.fold<double>(0, (sum, line) => sum + line.subtotal) -
      widget.pointsUsed;

  @override
  void initState() {
    super.initState();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining > Duration.zero) {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
    _detect = Timer(AppStore.paymentDetectDelay, _onPaymentDetected);
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _detect?.cancel();
    super.dispose();
  }

  /// ระบบตรวจพบยอดโอน: สร้างออเดอร์ แสดงสถานะยืนยันแล้วครู่หนึ่ง แล้วไปหน้าใบเสร็จ
  Future<void> _onPaymentDetected() async {
    _countdown?.cancel();
    final order = appStore.placeOrder(
      shop: widget.shop,
      lines: widget.lines,
      pickupAt: widget.pickupAt,
      paymentMethod: widget.method,
      pointsUsed: widget.pointsUsed,
    );
    setState(() => _status = PaymentStatus.verified);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) Navigator.pop(context, order);
  }

  String get _remainingLabel =>
      '${_remaining.inMinutes.toString().padLeft(2, '0')}:'
      '${(_remaining.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final paid = _status == PaymentStatus.verified;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.method == PaymentMethod.promptPay
              ? 'สแกนเพื่อชำระเงิน'
              : 'โอนเงินผ่านธนาคาร',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const Text(
                    'ยอดที่ต้องชำระ',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  Text(
                    '฿${_amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.orangeDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.method == PaymentMethod.promptPay) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE8E3DE)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 190,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'พร้อมเพย์ ${PlatformConfig.promptPayId}',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.account_balance_rounded,
                      size: 64,
                      color: AppColors.orange,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      PlatformConfig.bankAccount,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                  const Text(
                    'ชื่อบัญชี ${PlatformConfig.accountName}',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ชำระภายใน $_remainingLabel นาที',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _status.color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                if (paid)
                  Icon(Icons.check_circle_rounded, color: _status.color)
                else
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _status.color,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paid ? 'ได้รับเงินแล้ว' : 'รอการชำระเงิน',
                        key: const Key('payment-status'),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _status.color,
                        ),
                      ),
                      Text(
                        paid
                            ? 'ระบบยืนยันยอดโอนเรียบร้อย กำลังส่งออเดอร์ให้ร้าน'
                            : 'ระบบจะตรวจสอบยอดโอนให้อัตโนมัติ ไม่ต้องแนบสลิป',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (!paid)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิกการชำระเงิน'),
            ),
        ],
      ),
    );
  }
}
