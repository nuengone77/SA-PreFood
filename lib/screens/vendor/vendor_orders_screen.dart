import 'package:flutter/material.dart';

import '../../app_store.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// หน้าคิวออเดอร์ของร้านค้า เรียงตามเวลานัดรับ (Kitchen Order Management)
/// ร้านรับ/ปฏิเสธออเดอร์ที่ลูกค้าชำระผ่าน PreFood แล้ว อัปเดตสถานะ และสแกน QR ยืนยันการรับอาหาร
class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  // null หมายถึงแสดงทุกสถานะ
  OrderStage? _filter;

  static const _filters = [
    OrderStage.pending,
    OrderStage.cooking,
    OrderStage.ready,
    OrderStage.completed,
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) {
        final visible = appStore.vendorOrders
            .where((order) => _filter == null || order.stage == _filter)
            .toList();
        return SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              const PageIntro(
                title: 'ออเดอร์',
                subtitle: 'เรียงตามเวลานัดรับ • รับออเดอร์และอัปเดตสถานะอาหาร',
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [null, ..._filters]
                      .map(
                        (stage) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(stage?.label ?? 'ทั้งหมด'),
                            selected: _filter == stage,
                            onSelected: (_) => setState(() => _filter = stage),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 18),
              if (visible.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'ไม่มีออเดอร์ในสถานะนี้',
                    message: 'ออเดอร์ใหม่จะปรากฏที่นี่',
                  ),
                )
              else
                ...visible.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        OrderSummaryCard(
                          order: order,
                          showCustomer: true,
                          actions: _actionsFor(order),
                        ),
                        _PaymentStrip(order: order),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// คืนชุดปุ่มที่เหมาะกับสถานะปัจจุบันของออเดอร์
  List<Widget> _actionsFor(MockOrder order) {
    return switch (order.stage) {
      OrderStage.pending => [
        OutlinedButton(
          onPressed: () => appStore.rejectOrder(order),
          child: const Text('ปฏิเสธ'),
        ),
        FilledButton(
          key: Key('accept-${order.id}'),
          // รับออเดอร์ได้เมื่อ PreFood ยืนยันว่าลูกค้าชำระเงินแล้ว
          onPressed: order.paymentStatus == PaymentStatus.verified
              ? () => appStore.acceptOrder(order)
              : null,
          child: const Text('รับออเดอร์'),
        ),
      ],
      OrderStage.cooking => [
        FilledButton.icon(
          onPressed: () => appStore.updateStage(order, OrderStage.ready),
          icon: const Icon(Icons.check_rounded),
          label: const Text('อาหารพร้อมรับ'),
        ),
      ],
      OrderStage.ready => [
        FilledButton.tonalIcon(
          onPressed: () => _scanPickupQr(order),
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('สแกน QR รับอาหาร'),
        ),
      ],
      OrderStage.completed || OrderStage.rejected => const [],
    };
  }

  /// จำลองการสแกน QR Code ของลูกค้าเพื่อยืนยันการรับอาหาร (รายงานข้อ 3.5.1)
  Future<void> _scanPickupQr(MockOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 40),
        title: const Text('สแกน QR สำเร็จ'),
        content: Text(
          '${order.id} • คิว ${order.queueLabel}\n'
          'ลูกค้า: ${order.customerName}\n${order.items}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ส่งมอบอาหาร'),
          ),
        ],
      ),
    );
    if (confirmed == true) appStore.updateStage(order, OrderStage.completed);
  }
}

/// แถบสถานะการชำระเงินและยอดที่ร้านจะได้รับจาก PreFood
class _PaymentStrip extends StatelessWidget {
  const _PaymentStrip({required this.order});
  final MockOrder order;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (order.paymentStatus) {
      PaymentStatus.verifying => ('รอลูกค้าชำระ', order.paymentStatus.color),
      PaymentStatus.verified => ('ลูกค้าชำระแล้ว', order.paymentStatus.color),
      PaymentStatus.refunded => (
        'คืนเงินลูกค้าแล้ว',
        order.paymentStatus.color,
      ),
    };
    final rejected = order.stage == OrderStage.rejected;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Row(
        children: [
          StatusPill(label: label, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rejected
                  ? 'ไม่มีรายได้จากออเดอร์นี้'
                  // ไม่โอนรายออเดอร์ ยอดนี้นับรวมในยอดโอนรายเดือน
                  : 'ร้านได้รับ ฿${order.shopPayout.toStringAsFixed(0)} '
                        '• รวมในยอด ${formatThaiMonthYear(order.orderedAt)}',
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
