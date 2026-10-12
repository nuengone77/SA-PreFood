import 'package:flutter/material.dart';

import '../../app_store.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'order_history_screen.dart';

/// หน้าติดตามสถานะออเดอร์ ฟัง [appStore] จึงเปลี่ยนตามที่ร้านอัปเดตทันที
/// และแจ้งเตือนด้วย SnackBar ทุกครั้งที่สถานะเปลี่ยน (รายงานข้อ 2.1.3)
/// ปุ่ม "จำลองสถานะถัดไป" ใช้สาธิตแทนการกดจากฝั่งร้านค้า
class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key, required this.order});
  final MockOrder order;

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  // ลำดับสถานะที่ลูกค้าจะเห็น ตั้งแต่รอยืนยันจนรับอาหารสำเร็จ
  static const stages = [
    OrderStage.pending,
    OrderStage.cooking,
    OrderStage.ready,
    OrderStage.completed,
  ];

  // ต้องตั้งค่าใน initState ถ้าใช้ late แบบ lazy ค่าจะถูกอ่านครั้งแรกหลังสถานะเปลี่ยนแล้ว
  // ทำให้การเปลี่ยนสถานะครั้งแรกไม่ถูกแสดงและไม่แจ้งเตือน
  late OrderStage _lastStage;

  @override
  void initState() {
    super.initState();
    _lastStage = widget.order.stage;
    appStore.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    appStore.removeListener(_onStoreChanged);
    super.dispose();
  }

  /// แจ้งเตือนเมื่อสถานะออเดอร์เปลี่ยน
  void _onStoreChanged() {
    final stage = widget.order.stage;
    if (stage == _lastStage || !mounted) return;
    _lastStage = stage;
    setState(() {});
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('${widget.order.id}: ${stage.label}')),
            ],
          ),
        ),
      );
  }

  /// จำลองการกดปุ่มจากฝั่งร้านค้า
  void _advance() {
    final order = widget.order;
    switch (order.stage) {
      case OrderStage.pending:
        appStore.acceptOrder(order);
      case OrderStage.cooking:
        appStore.updateStage(order, OrderStage.ready);
      case OrderStage.ready:
        appStore.updateStage(order, OrderStage.completed);
      case OrderStage.completed || OrderStage.rejected:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final stage = order.stage;
    final rejected = stage == OrderStage.rejected;
    final step = rejected ? 0 : stages.indexOf(stage);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'สถานะออเดอร์',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: stage.color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: stage.color.withValues(alpha: .18),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: Icon(
                    switch (stage) {
                      OrderStage.pending => Icons.hourglass_top_rounded,
                      OrderStage.cooking => Icons.soup_kitchen_rounded,
                      OrderStage.ready => Icons.takeout_dining_rounded,
                      OrderStage.completed => Icons.check_circle_rounded,
                      OrderStage.rejected => Icons.cancel_rounded,
                    },
                    size: 48,
                    color: stage.color,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  stage.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: stage.color,
                    fontSize: 23,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  switch (stage) {
                    OrderStage.pending => 'ชำระเงินแล้ว รอร้านยืนยันออเดอร์',
                    OrderStage.cooking => 'ร้านกำลังปรุงอาหารของคุณ',
                    OrderStage.ready =>
                      'ไปรับอาหารที่ร้านได้เลย แสดง QR Code ด้านล่างให้ร้านสแกน',
                    OrderStage.completed =>
                      'รับอาหารเรียบร้อย ได้รับ ${order.pointsEarned} แต้มสะสม',
                    OrderStage.rejected =>
                      'ร้านไม่สามารถรับออเดอร์นี้ได้ PreFood คืนเงินและแต้มให้แล้ว',
                  },
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                Text(
                  'คิว ${order.queueLabel}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          if (!rejected) ...[
            const SizedBox(height: 26),
            Row(
              children: List.generate(
                stages.length,
                (index) => Expanded(
                  flex: index < stages.length - 1 ? 1 : 0,
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index <= step
                              ? stages[index].color
                              : const Color(0xFFE8E3DE),
                        ),
                        child: Icon(
                          index < step || stage == OrderStage.completed
                              ? Icons.check_rounded
                              : Icons.circle,
                          size: index < step ? 18 : 8,
                          color: Colors.white,
                        ),
                      ),
                      if (index < stages.length - 1)
                        Expanded(
                          child: Container(
                            height: 3,
                            color: index < step
                                ? stages[index].color
                                : const Color(0xFFE8E3DE),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: stages
                  .map(
                    (s) => Text(s.label, style: const TextStyle(fontSize: 11)),
                  )
                  .toList(),
            ),
          ],
          if (stage == OrderStage.ready) ...[
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Text(
                      'QR Code ยืนยันการรับอาหาร',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 150,
                      color: AppColors.ink,
                    ),
                    Text(
                      '${order.id} • ${order.queueLabel}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          OrderSummaryCard(order: order),
          const SizedBox(height: 16),
          if (stage == OrderStage.completed && order.rating == null)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () => showRatingDialog(context, order),
              icon: const Icon(Icons.star_rounded),
              label: const Text('ให้คะแนนร้าน'),
            )
          else if (stage == OrderStage.completed || rejected)
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('กลับหน้าหลัก'),
            )
          else
            OutlinedButton.icon(
              key: const Key('simulate-next'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _advance,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('จำลองสถานะถัดไป (ฝั่งร้านค้า)'),
            ),
        ],
      ),
    );
  }
}
