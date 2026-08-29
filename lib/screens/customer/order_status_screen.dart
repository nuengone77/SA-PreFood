import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key, required this.order});
  final MockOrder order;

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  int _step = 0;
  final stages = [OrderStage.pending, OrderStage.cooking, OrderStage.ready];

  void _advance() {
    if (_step < stages.length - 1) setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    final stage = stages[_step];
    widget.order.stage = stage;
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
                    _step == 0
                        ? Icons.hourglass_top_rounded
                        : _step == 1
                        ? Icons.soup_kitchen_rounded
                        : Icons.check_circle_rounded,
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
                  _step == 0
                      ? 'ส่งออเดอร์ให้ร้านแล้ว กรุณารอสักครู่'
                      : _step == 1
                      ? 'ร้านกำลังเตรียมอาหารของคุณ'
                      : 'ไปรับอาหารที่หน้าร้านได้เลย!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Row(
            children: List.generate(
              stages.length,
              (index) => Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index <= _step
                            ? stages[index].color
                            : const Color(0xFFE8E3DE),
                      ),
                      child: Icon(
                        index < _step ? Icons.check_rounded : Icons.circle,
                        size: index < _step ? 18 : 8,
                        color: Colors.white,
                      ),
                    ),
                    if (index < stages.length - 1)
                      Expanded(
                        child: Container(
                          height: 3,
                          color: index < _step
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
            children: const [
              Text('รอรับ', style: TextStyle(fontSize: 11)),
              Text('กำลังทำ', style: TextStyle(fontSize: 11)),
              Text('พร้อมรับ', style: TextStyle(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 26),
          OrderSummaryCard(order: widget.order),
          const SizedBox(height: 16),
          if (_step < stages.length - 1)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _advance,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('จำลองสถานะถัดไป'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('กลับหน้าหลัก'),
              ),
            ),
        ],
      ),
    );
  }
}
