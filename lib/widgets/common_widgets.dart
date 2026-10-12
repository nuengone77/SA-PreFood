import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

/// โลโก้ PreFood แบบสร้างจาก Material Icon จึงไม่ต้องพึ่งไฟล์รูปภายนอก
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 74});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * .3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A9E582F),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.restaurant_rounded,
        color: AppColors.orange,
        size: size * .52,
      ),
    );
  }
}

/// ส่วนหัวมาตรฐานของหน้า แสดงหัวข้อ คำอธิบาย และ widget ด้านขวาได้
class PageIntro extends StatelessWidget {
  const PageIntro({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        ...switch (trailing) {
          null => const <Widget>[],
          final widget => <Widget>[widget],
        },
      ],
    );
  }
}

/// ภาพตัวอย่างอาหารหรือร้านค้า ใช้ emoji บนพื้นหลังไล่สีแทน asset จริง
class EmojiVisual extends StatelessWidget {
  const EmojiVisual({
    super.key,
    required this.emoji,
    required this.color,
    this.height = 116,
    this.width,
  });
  final String emoji;
  final Color color;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: .62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: height * .46)),
    );
  }
}

/// ป้ายสถานะขนาดเล็ก เช่น เปิดร้าน กำลังทำ หรือพร้อมรับ
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// หน้าสถานะว่างสำหรับกรณีไม่มีข้อมูล เช่น ตะกร้าว่างหรือค้นหาไม่พบ
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: AppColors.orange),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// การ์ดสรุปข้อมูลออเดอร์ที่ใช้ซ้ำในหน้าประวัติและหน้าร้านค้า
/// รับ [actions] เพื่อให้แต่ละหน้าส่งปุ่มคำสั่งที่ต่างกันเข้ามาได้
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.order,
    this.actions = const [],
    this.showCustomer = false,
  });
  final MockOrder order;
  final List<Widget> actions;

  /// true ในหน้าร้านค้า เพื่อแสดงชื่อลูกค้าแทนชื่อร้าน
  final bool showCustomer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${order.id} • คิว ${order.queueLabel}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                StatusPill(label: order.stage.label, color: order.stage.color),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              showCustomer ? 'ลูกค้า: ${order.customerName}' : order.shopName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(order.items, style: const TextStyle(color: AppColors.muted)),
            if (order.pointsUsed > 0 || order.pointsEarned > 0) ...[
              const SizedBox(height: 4),
              Text(
                [
                  if (order.pointsUsed > 0)
                    'ใช้ ${order.pointsUsed} แต้ม ลด ฿${order.discount.toStringAsFixed(0)}',
                  if (order.pointsEarned > 0)
                    'ได้รับ ${order.pointsEarned} แต้ม',
                ].join(' • '),
                style: const TextStyle(color: AppColors.green, fontSize: 12),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'สั่งเมื่อ ${formatDateTime(order.orderedAt)} • ${order.paymentMethod.label}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'นัดรับ ${formatDateTime(order.pickupAt)}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
                Text(
                  '฿${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                children: actions
                    .map(
                      (e) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: e,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ตรวจช่องที่รายงานกำหนดว่า "บังคับ" ต้องไม่ว่าง
String? requiredField(String? value) =>
    (value == null || value.trim().isEmpty) ? 'กรุณากรอกข้อมูล' : null;

/// ตรวจเบอร์โทรศัพท์ไทย 9-10 หลัก (อนุญาตให้มีขีดคั่น)
String? phoneField(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return 'กรุณากรอกเบอร์โทรศัพท์';
  if (digits.length < 9 || digits.length > 10) return 'เบอร์โทรศัพท์ไม่ถูกต้อง';
  return null;
}
