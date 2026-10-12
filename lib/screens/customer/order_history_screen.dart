import 'package:flutter/material.dart';

import '../../app_store.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import 'profile_screen.dart';
import 'order_status_screen.dart';

/// แสดงประวัติการสั่งซื้อย้อนหลังของลูกค้า (รายงานข้อ 2.1.4)
/// ออเดอร์ที่ยังไม่เสร็จกดเข้าไปติดตามสถานะได้ ออเดอร์ที่สำเร็จให้คะแนนร้านได้
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) {
        final orders = appStore.myOrders;
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              const PageIntro(
                title: 'ประวัติการสั่งซื้อ',
                subtitle: 'ดูรายการย้อนหลัง ติดตามสถานะ และสั่งซ้ำได้',
              ),
              const SizedBox(height: 16),
              const PointsBalanceCard(),
              const SizedBox(height: 16),
              ...orders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderStatusScreen(order: order),
                      ),
                    ),
                    child: OrderSummaryCard(
                      order: order,
                      actions: _actionsFor(context, order),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _actionsFor(BuildContext context, MockOrder order) {
    if (order.stage != OrderStage.completed) return const [];
    return [
      if (order.rating == null)
        FilledButton.tonalIcon(
          onPressed: () => showRatingDialog(context, order),
          icon: const Icon(Icons.star_outline_rounded),
          label: const Text('ให้คะแนน'),
        )
      else
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (i) => Icon(
                i < order.rating! ? Icons.star_rounded : Icons.star_border,
                color: const Color(0xFFFFB33A),
                size: 20,
              ),
            ),
          ),
        ),
      OutlinedButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เพิ่มเมนูเดิมลงตะกร้าแล้ว (ตัวอย่าง)')),
        ),
        icon: const Icon(Icons.replay_rounded),
        label: const Text('สั่งซ้ำ'),
      ),
    ];
  }
}

/// กล่องให้คะแนนร้านหลังรับอาหาร (รายงานข้อ 4.1.1)
Future<void> showRatingDialog(BuildContext context, MockOrder order) async {
  var rating = 5;
  final result = await showDialog<int>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('ให้คะแนน ${order.shopName}'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (i) => IconButton(
              onPressed: () => setState(() => rating = i + 1),
              icon: Icon(
                i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: const Color(0xFFFFB33A),
                size: 34,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ภายหลัง'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, rating),
            child: const Text('ส่งคะแนน'),
          ),
        ],
      ),
    ),
  );
  if (result != null) appStore.rateOrder(order, result);
}
