import 'package:flutter/material.dart';

import '../../app_store.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'order_status_screen.dart';

/// หน้ายืนยันการชำระเงินและใบสั่งอาหาร/ใบเสร็จอิเล็กทรอนิกส์
/// แสดงข้อมูลตามรายงานข้อ 2.1.1 และ 2.1.2 เช่น วิธีชำระเงิน สถานะการตรวจสอบ
/// หมายเลขคิว รหัสออเดอร์ และเวลาที่ทำรายการ
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.order});
  final MockOrder order;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'ใบเสร็จ',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: AppColors.green,
            ),
            const SizedBox(height: 8),
            const Text(
              'ส่งคำสั่งซื้อเรียบร้อย',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Text(
                      'หมายเลขคิว',
                      style: TextStyle(color: AppColors.muted),
                    ),
                    Text(
                      order.queueLabel,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: AppColors.orangeDark,
                      ),
                    ),
                    const Divider(height: 24),
                    _Row(label: 'รหัสออเดอร์', value: order.id),
                    _Row(label: 'ร้านค้า', value: order.shopName),
                    _Row(
                      label: 'เวลาที่ทำรายการ',
                      value: formatDateTime(order.orderedAt),
                    ),
                    _Row(
                      label: 'นัดรับอาหาร',
                      value: formatDateTime(order.pickupAt),
                    ),
                    const Divider(height: 24),
                    ...order.lines.map(
                      (line) => _Row(
                        label: line.summary,
                        value: '฿${line.subtotal.toStringAsFixed(0)}',
                      ),
                    ),
                    if (order.pointsUsed > 0)
                      _Row(
                        label: 'ส่วนลดจากแต้มสะสม (${order.pointsUsed} แต้ม)',
                        value: '-฿${order.discount.toStringAsFixed(0)}',
                      ),
                    const Divider(height: 24),
                    _Row(
                      label: 'ยอดรวม',
                      value: '฿${order.total.toStringAsFixed(0)}',
                      emphasized: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'การชำระเงิน',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        StatusPill(
                          label: order.paymentStatus.label,
                          color: order.paymentStatus.color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const _Row(
                      label: 'ชำระให้',
                      value: 'PreFood (${PlatformConfig.accountName})',
                    ),
                    _Row(
                      label: 'วิธีชำระเงิน',
                      value: order.paymentMethod.label,
                    ),
                    _Row(
                      label: 'วันที่',
                      value: formatThaiDate(order.orderedAt),
                    ),
                    _Row(label: 'เวลา', value: formatTime(order.orderedAt)),
                    _Row(
                      label: 'จำนวนเงิน',
                      value: '฿${order.total.toStringAsFixed(0)}',
                    ),
                    _Row(
                      label: 'แต้มที่จะได้รับเมื่อรับอาหาร',
                      value: '${AppStore.pointsFor(order.total)} แต้ม',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('track-order'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderStatusScreen(order: order),
                ),
              ),
              icon: const Icon(Icons.track_changes_rounded),
              label: const Text('ติดตามสถานะออเดอร์'),
            ),
          ],
        ),
      ),
    );
  }
}

/// แถวข้อมูลแบบ label ซ้าย ค่าอยู่ขวา
class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.emphasized = false,
  });
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? AppColors.ink : AppColors.muted,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: emphasized ? 18 : 14,
            color: emphasized ? AppColors.orangeDark : AppColors.ink,
          ),
        ),
      ],
    ),
  );
}
