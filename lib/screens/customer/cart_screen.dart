import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    required this.cart,
    required this.onAdd,
    required this.onRemove,
    required this.onBrowse,
    required this.onCheckout,
  });
  final Map<FoodItem, int> cart;
  final ValueChanged<FoodItem> onAdd;
  final ValueChanged<FoodItem> onRemove;
  final VoidCallback onBrowse;
  final ValueChanged<String> onCheckout;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _pickup = '12:15';

  @override
  Widget build(BuildContext context) {
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

    final subtotal = widget.cart.entries.fold<double>(
      0,
      (sum, e) => sum + e.key.price * e.value,
    );
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          PageIntro(
            title: 'ตะกร้าของฉัน',
            subtitle: '${widget.cart.length} เมนู • ครัวป้าแดง',
          ),
          const SizedBox(height: 20),
          ...widget.cart.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      EmojiVisual(
                        emoji: entry.key.emoji,
                        color: entry.key.color,
                        height: 76,
                        width: 76,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key.name,
                              maxLines: 2,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              '฿${entry.key.price.toStringAsFixed(0)}',
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
                                widget.onRemove(entry.key);
                                setState(() {});
                              },
                              icon: const Icon(Icons.remove_rounded),
                              visualDensity: VisualDensity.compact,
                            ),
                            Text(
                              '${entry.value}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                widget.onAdd(entry.key);
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
            'เลือกรอบรับอาหาร',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ['12:15', '12:30', '12:45', '13:00']
                .map(
                  (time) => ChoiceChip(
                    label: Text(time),
                    selected: time == _pickup,
                    onSelected: (_) => setState(() => _pickup = time),
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
              onPressed: () => widget.onCheckout(_pickup),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text('ยืนยันสั่งซื้อ • ฿${subtotal.toStringAsFixed(0)}'),
            ),
          ),
        ],
      ),
    );
  }
}

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
