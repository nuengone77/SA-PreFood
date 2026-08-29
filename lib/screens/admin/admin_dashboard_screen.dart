import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const PageIntro(
          title: 'สวัสดี, ผู้ดูแลระบบ',
          subtitle: 'ข้อมูลล่าสุด ณ วันนี้ เวลา 12:05 น.',
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 740 ? 4 : 2;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _AdminStat(
                  width: width,
                  icon: Icons.people_rounded,
                  label: 'ผู้ใช้ทั้งหมด',
                  value: '1,248',
                  change: '+24 สัปดาห์นี้',
                  color: const Color(0xFF4D83C4),
                ),
                _AdminStat(
                  width: width,
                  icon: Icons.storefront_rounded,
                  label: 'ร้านค้า',
                  value: '32',
                  change: '2 รออนุมัติ',
                  color: AppColors.orange,
                ),
                _AdminStat(
                  width: width,
                  icon: Icons.receipt_long_rounded,
                  label: 'ออเดอร์ทั้งหมด',
                  value: '8,946',
                  change: '+8.2% เดือนนี้',
                  color: AppColors.green,
                ),
                _AdminStat(
                  width: width,
                  icon: Icons.payments_rounded,
                  label: 'ยอดขายรวม',
                  value: '฿428K',
                  change: '+12.4% เดือนนี้',
                  color: const Color(0xFF98703E),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        Text(
          'กิจกรรมล่าสุด',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: const [
              _Activity(
                icon: Icons.storefront_rounded,
                color: AppColors.orange,
                title: 'ร้าน “ข้าวมันไก่คุณยาย” สมัครใหม่',
                time: '5 นาทีที่แล้ว',
              ),
              Divider(height: 1, indent: 66),
              _Activity(
                icon: Icons.person_add_alt_1_rounded,
                color: Color(0xFF4D83C4),
                title: 'มีผู้ใช้ใหม่ 8 คน',
                time: '25 นาทีที่แล้ว',
              ),
              Divider(height: 1, indent: 66),
              _Activity(
                icon: Icons.report_problem_rounded,
                color: Color(0xFFC94B4B),
                title: 'ได้รับรายงานปัญหาออเดอร์ #A1025',
                time: '1 ชั่วโมงที่แล้ว',
              ),
              Divider(height: 1, indent: 66),
              _Activity(
                icon: Icons.check_circle_rounded,
                color: AppColors.green,
                title: 'ออเดอร์ครบ 500 รายการในสัปดาห์นี้',
                time: '2 ชั่วโมงที่แล้ว',
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'สุขภาพระบบ',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_done_rounded,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ทุกระบบทำงานปกติ',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'อัปเดตล่าสุด 1 นาทีที่แล้ว',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const StatusPill(label: 'Online', color: AppColors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminStat extends StatelessWidget {
  const _AdminStat({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    required this.color,
  });
  final double width;
  final IconData icon;
  final String label;
  final String value;
  final String change;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            Text(
              label,
              maxLines: 1,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              change,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Activity extends StatelessWidget {
  const _Activity({
    required this.icon,
    required this.color,
    required this.title,
    required this.time,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 21),
    ),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
    subtitle: Text(
      time,
      style: const TextStyle(color: AppColors.muted, fontSize: 11),
    ),
  );
}
