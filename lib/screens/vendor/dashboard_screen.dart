import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// Dashboard ร้านค้า แสดงสถิติประจำวัน ออเดอร์ใหม่ และกราฟอย่างง่าย
class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key, required this.onViewOrders});
  final VoidCallback onViewOrders;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          PageIntro(
            title: 'สวัสดีตอนเที่ยง 👋',
            subtitle: 'ภาพรวมร้านของคุณวันนี้',
            trailing: StatusPill(label: 'ร้านเปิดอยู่', color: AppColors.green),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    width: width,
                    icon: Icons.fiber_new_rounded,
                    label: 'ออเดอร์ใหม่',
                    value: '1',
                    color: AppColors.orange,
                  ),
                  _StatCard(
                    width: width,
                    icon: Icons.soup_kitchen_rounded,
                    label: 'กำลังทำ',
                    value: '1',
                    color: const Color(0xFF4D83C4),
                  ),
                  _StatCard(
                    width: width,
                    icon: Icons.check_circle_rounded,
                    label: 'เสร็จแล้ว',
                    value: '18',
                    color: AppColors.green,
                  ),
                  _StatCard(
                    width: width,
                    icon: Icons.payments_outlined,
                    label: 'ยอดขาย',
                    value: '฿1,245',
                    color: const Color(0xFF927044),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2F8064), Color(0xFF49A07F)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'มีออเดอร์ใหม่เข้ามา!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '#A1042 • รับเวลา 12:15',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .82),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.tonal(
                        onPressed: onViewOrders,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(130, 42),
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.green,
                        ),
                        child: const Text('ดูออเดอร์'),
                      ),
                    ],
                  ),
                ),
                const Text('🧾', style: TextStyle(fontSize: 62)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ช่วงเวลาขายดี',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_graph_rounded, color: AppColors.orange),
                      SizedBox(width: 8),
                      Text(
                        'จำนวนออเดอร์รายชั่วโมง',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 112,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        _MiniBar(label: '10', value: .28),
                        _MiniBar(label: '11', value: .58),
                        _MiniBar(label: '12', value: 1),
                        _MiniBar(label: '13', value: .72),
                        _MiniBar(label: '14', value: .4),
                        _MiniBar(label: '15', value: .25),
                      ],
                    ),
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

/// การ์ดสถิติขนาดเล็กที่ใช้กับตัวเลขสรุปแต่ละประเภท
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
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
    ),
  );
}

/// แท่งกราฟรายชั่วโมงแบบไม่ใช้ chart package ภายนอก
class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: value,
              child: Container(
                width: 22,
                decoration: BoxDecoration(
                  color: value == 1
                      ? AppColors.orange
                      : AppColors.orange.withValues(alpha: .28),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(7),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    ),
  );
}
