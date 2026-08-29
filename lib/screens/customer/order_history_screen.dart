import 'package:flutter/material.dart';

import '../../mock_data.dart';
import '../../widgets/common_widgets.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          const PageIntro(
            title: 'ประวัติการสั่งซื้อ',
            subtitle: 'ดูรายการย้อนหลังและสั่งซ้ำได้',
          ),
          const SizedBox(height: 20),
          ...customerHistory.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OrderSummaryCard(
                order: order,
                actions: [
                  OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('เพิ่มเมนูเดิมลงตะกร้าแล้ว (ตัวอย่าง)'),
                      ),
                    ),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('สั่งซ้ำ'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
