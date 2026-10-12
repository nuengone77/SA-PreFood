import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// หน้าตะกร้าของลูกค้า รับข้อมูลและ callback จาก [CustomerShell]
/// จึงมีหน้าที่แสดงผลและส่งคำสั่งกลับไปยังเจ้าของ state
class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    required this.cart,
    required this.shop,
    required this.onAdd,
    required this.onRemove,
    required this.onBrowse,
    required this.onCheckout,
  });
  final List<CartLine> cart;
  final Shop? shop;
  final ValueChanged<CartLine> onAdd;
  final ValueChanged<CartLine> onRemove;
  final VoidCallback onBrowse;
  final ValueChanged<DateTime> onCheckout;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // รอบรับอาหารทุก 30 นาทีตามเวลาเปิดโรงอาหาร 08:00–16:30
  static final _slots = [
    for (var minutes = 8 * 60; minutes <= 16 * 60; minutes += 30)
      Duration(minutes: minutes),
  ];

  // วันที่และรอบรับอาหารที่ลูกค้าเลือก
  late DateTime _date = _availableDates().first;
  Duration? _slot;

  /// สั่งล่วงหน้าได้ 3 วัน ถ้าวันนี้ไม่เหลือรอบแล้วจะเริ่มจากพรุ่งนี้
  List<DateTime> _availableDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var i = 0; i < 4; i++) today.add(Duration(days: i)),
    ].where((date) => _slotsFor(date).isNotEmpty).take(3).toList();
  }

  /// รอบที่เลือกได้ ต้องห่างจากเวลาปัจจุบันอย่างน้อย 15 นาทีให้ร้านเตรียมทัน
  List<Duration> _slotsFor(DateTime date) {
    final earliest = DateTime.now().add(const Duration(minutes: 15));
    return _slots.where((slot) => date.add(slot).isAfter(earliest)).toList();
  }

  String _dateLabel(DateTime date) {
    final today = DateTime.now();
    if (date.day == today.day && date.month == today.month) {
      return 'วันนี้ ${formatThaiDate(date)}';
    }
    final tomorrow = today.add(const Duration(days: 1));
    if (date.day == tomorrow.day && date.month == tomorrow.month) {
      return 'พรุ่งนี้ ${formatThaiDate(date)}';
    }
    return formatThaiDate(date);
  }

  @override
  Widget build(BuildContext context) {
    // แสดง Empty State และปุ่มกลับไปเลือกร้านเมื่อยังไม่มีสินค้า
    if (widget.cart.isEmpty) {
      return SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: PageIntro(
                title: 'ตะกร้าของฉัน',
                subtitle: 'รายการที่เลือกจะอยู่ที่นี่',
              ),
            ),
            Expanded(
              child: EmptyState(
                icon: Icons.shopping_bag_outlined,
                title: 'ตะกร้ายังว่าง',
                message: 'เลือกร้านและเพิ่มเมนูโปรดของคุณ',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: widget.onBrowse,
                  child: const Text('ไปเลือกร้าน'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // คำนวณยอดรวมจากราคา x จำนวนของทุกรายการในตะกร้า
    final subtotal = widget.cart.fold<double>(
      0,
      (sum, line) => sum + line.subtotal,
    );
    final slots = _slotsFor(_date);
    final slot = slots.contains(_slot) ? _slot! : slots.first;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          PageIntro(
            title: 'ตะกร้าของฉัน',
            subtitle:
                '${widget.cart.length} รายการ • ${widget.shop?.name ?? ''}',
          ),
          const SizedBox(height: 20),
          ...widget.cart.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      EmojiVisual(
                        emoji: line.item.emoji,
                        color: line.item.color,
                        height: 76,
                        width: 76,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.item.name,
                              maxLines: 2,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (line.note.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                'หมายเหตุ: ${line.note}',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 7),
                            Text(
                              '฿${line.subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.orangeDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                widget.onRemove(line);
                                setState(() {});
                              },
                              icon: const Icon(Icons.remove_rounded),
                              visualDensity: VisualDensity.compact,
                            ),
                            Text(
                              '${line.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                widget.onAdd(line);
                                setState(() {});
                              },
                              icon: const Icon(Icons.add_rounded),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'วันและเวลานัดรับอาหาร',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _availableDates()
                .map(
                  (date) => ChoiceChip(
                    avatar: const Icon(Icons.event_rounded, size: 18),
                    label: Text(_dateLabel(date)),
                    selected: date == _date,
                    onSelected: (_) => setState(() => _date = date),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: slots
                .map(
                  (time) => ChoiceChip(
                    label: Text(formatTime(_date.add(time))),
                    selected: time == slot,
                    onSelected: (_) => setState(() => _slot = time),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _PriceRow(label: 'ค่าอาหาร', value: subtotal),
                  const SizedBox(height: 10),
                  const _PriceRow(label: 'ค่าบริการ', value: 0),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _PriceRow(label: 'ยอดรวม', value: subtotal, emphasized: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('cart-checkout'),
              onPressed: () => widget.onCheckout(_date.add(slot)),
              icon: const Icon(Icons.payments_outlined),
              label: Text('ไปชำระเงิน • ฿${subtotal.toStringAsFixed(0)}'),
            ),
          ),
        ],
      ),
    );
  }
}

/// แถวแสดงราคา ใช้ซ้ำกับค่าอาหาร ค่าบริการ และยอดรวม
class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });
  final String label;
  final double value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: TextStyle(
          fontWeight: emphasized ? FontWeight.w800 : FontWeight.w400,
          color: emphasized ? AppColors.ink : AppColors.muted,
        ),
      ),
      const Spacer(),
      Text(
        value == 0 ? 'ฟรี' : '฿${value.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: emphasized ? 19 : 14,
          fontWeight: FontWeight.w900,
          color: emphasized ? AppColors.orangeDark : AppColors.ink,
        ),
      ),
    ],
  );
}
