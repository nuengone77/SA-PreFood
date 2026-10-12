import 'package:flutter/material.dart';

import '../../app_store.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// แสดงข้อมูลร้านและเมนูทั้งหมด พร้อมปุ่มเพิ่มสินค้าลงตะกร้า
/// ฟัง [appStore] เพื่อให้สถานะสินค้าหมดที่ร้านตั้งไว้แสดงทันที
class ShopMenuScreen extends StatefulWidget {
  const ShopMenuScreen({
    super.key,
    required this.shopId,
    required this.onAdd,
    required this.cartCount,
    required this.onViewCart,
  });
  final String shopId;

  /// คืนค่า true เมื่อเพิ่มลงตะกร้าสำเร็จ
  final Future<bool> Function(CartLine line) onAdd;
  final int Function() cartCount;
  final VoidCallback onViewCart;

  @override
  State<ShopMenuScreen> createState() => _ShopMenuScreenState();
}

class _ShopMenuScreenState extends State<ShopMenuScreen> {
  /// เปิด bottom sheet ให้เลือกจำนวน ตัวเลือกเพิ่มเติม และหมายเหตุ
  Future<void> _openAddSheet(FoodItem item) async {
    final line = await showModalBottomSheet<CartLine>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AddToCartSheet(item: item),
    );
    if (line == null || !mounted) return;
    final added = await widget.onAdd(line);
    if (!added || !mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text('เพิ่ม ${line.summary} แล้ว'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) {
        final shop = appStore.shopById(widget.shopId);
        final cartCount = widget.cartCount();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              shop.name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  child: IconButton(
                    onPressed: widget.onViewCart,
                    icon: const Icon(Icons.shopping_bag_outlined),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: shop.color,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Text(shop.emoji, style: const TextStyle(fontSize: 62)),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            shop.description,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFA51F),
                                size: 19,
                              ),
                              Text(
                                ' ${shop.rating}  •  ${shop.waitMinutes} นาที',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'เมนูทั้งหมด',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              ...shop.menu.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Opacity(
                    opacity: item.isAvailable ? 1 : .55,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            EmojiVisual(
                              emoji: item.emoji,
                              color: item.color,
                              height: 92,
                              width: 92,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      if (!item.isAvailable)
                                        StatusPill(
                                          label: item.stockLabel,
                                          color: Colors.red.shade500,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        '฿${item.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: AppColors.orangeDark,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton.filled(
                                        key: Key('add-${item.id}'),
                                        tooltip: 'เพิ่มลงตะกร้า',
                                        onPressed: item.isAvailable
                                            ? () => _openAddSheet(item)
                                            : null,
                                        icon: const Icon(Icons.add_rounded),
                                      ),
                                    ],
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
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ตัวเลือกเพิ่มเติมแบบกดเลือกได้ทันที ลูกค้าพิมพ์หมายเหตุอื่นเพิ่มได้
const _quickOptions = [
  'ไม่เผ็ด',
  'เผ็ดน้อย',
  'เผ็ดมาก',
  'ไม่ใส่ผัก',
  'แยกน้ำ',
  'ใส่กล่อง',
];

/// ฟอร์มเพิ่มเมนูลงตะกร้า (Use case: add to cart + custom order options)
class _AddToCartSheet extends StatefulWidget {
  const _AddToCartSheet({required this.item});
  final FoodItem item;

  @override
  State<_AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<_AddToCartSheet> {
  int _quantity = 1;
  final Set<String> _options = {};
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// รวมตัวเลือกที่กดและข้อความที่พิมพ์เป็นหมายเหตุเดียว
  String get _combinedNote => [
    ..._quickOptions.where(_options.contains),
    if (_note.text.trim().isNotEmpty) _note.text.trim(),
  ].join(', ');

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EmojiVisual(
                  emoji: item.emoji,
                  color: item.color,
                  height: 64,
                  width: 64,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        '฿${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.orangeDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  icon: const Icon(Icons.remove_rounded),
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'ตัวเลือกเพิ่มเติม',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _quickOptions
                  .map(
                    (option) => FilterChip(
                      label: Text(option),
                      selected: _options.contains(option),
                      onSelected: (selected) => setState(
                        () => selected
                            ? _options.add(option)
                            : _options.remove(option),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('item-note'),
              controller: _note,
              decoration: const InputDecoration(
                labelText: 'หมายเหตุพิเศษ (ถ้ามี)',
                hintText: 'เช่น แพ้กุ้ง, ไม่ใส่ผงชูรส',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('confirm-add'),
                onPressed: () => Navigator.pop(
                  context,
                  CartLine(
                    item: item,
                    quantity: _quantity,
                    note: _combinedNote,
                  ),
                ),
                child: Text(
                  'เพิ่มลงตะกร้า • ฿${(item.price * _quantity).toStringAsFixed(0)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
