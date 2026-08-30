import 'package:flutter/material.dart';

import '../../mock_data.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

/// หน้าคิวออเดอร์ของร้านค้า รองรับการกรองและเปลี่ยนสถานะออเดอร์
class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  // สร้างสำเนาออเดอร์สำหรับหน้านี้ และเก็บตัวกรองที่ผู้ใช้เลือก
  late final List<MockOrder> _orders = buildVendorOrders();
  String _filter = 'ทั้งหมด';

  @override
  Widget build(BuildContext context) {
    final visible = _orders
        .where((order) => _filter == 'ทั้งหมด' || order.stage.label == _filter)
        .toList();
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          const PageIntro(
            title: 'ออเดอร์',
            subtitle: 'จัดการคิวและอัปเดตสถานะอาหาร',
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['ทั้งหมด', 'รอร้านรับออเดอร์', 'กำลังทำ', 'พร้อมรับ']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (visible.isEmpty)
            const SizedBox(
              height: 350,
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
                child: OrderSummaryCard(
                  order: order,
                  actions: _actionsFor(order),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// คืนชุดปุ่มที่เหมาะกับสถานะปัจจุบันของออเดอร์
  /// เช่น ออเดอร์ใหม่มีปุ่มรับ/ปฏิเสธ ส่วนกำลังทำมีปุ่มทำเสร็จแล้ว
  List<Widget> _actionsFor(MockOrder order) {
    if (order.stage == OrderStage.pending) {
      return [
        OutlinedButton(
          onPressed: () => setState(() => order.stage = OrderStage.rejected),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade600),
          child: const Text('ปฏิเสธ'),
        ),
        FilledButton(
          onPressed: () => setState(() => order.stage = OrderStage.cooking),
          child: const Text('รับออเดอร์'),
        ),
      ];
    }
    if (order.stage == OrderStage.cooking) {
      return [
        FilledButton.icon(
          onPressed: () => setState(() => order.stage = OrderStage.ready),
          icon: const Icon(Icons.check_rounded),
          label: const Text('ทำเสร็จแล้ว'),
        ),
      ];
    }
    if (order.stage == OrderStage.ready) {
      return [
        FilledButton.tonal(
          onPressed: () => setState(() => order.stage = OrderStage.completed),
          child: const Text('ลูกค้ารับแล้ว'),
        ),
      ];
    }
    return [];
  }
}
