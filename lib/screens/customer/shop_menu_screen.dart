import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ShopMenuScreen extends StatefulWidget {
  const ShopMenuScreen({
    super.key,
    required this.shop,
    required this.onAdd,
    required this.cartCount,
    required this.onViewCart,
  });
  final Shop shop;
  final ValueChanged<FoodItem> onAdd;
  final int cartCount;
  final VoidCallback onViewCart;

  @override
  State<ShopMenuScreen> createState() => _ShopMenuScreenState();
}

class _ShopMenuScreenState extends State<ShopMenuScreen> {
  late int _cartCount;

  @override
  void initState() {
    super.initState();
    _cartCount = widget.cartCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.shop.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
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
              color: widget.shop.color,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Text(widget.shop.emoji, style: const TextStyle(fontSize: 62)),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.shop.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.shop.description,
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
                            ' ${widget.shop.rating}  •  ${widget.shop.waitMinutes} นาที',
                            style: const TextStyle(fontWeight: FontWeight.w700),
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
          ...widget.shop.menu.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
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
                                  tooltip: 'เพิ่มลงตะกร้า',
                                  onPressed: item.isAvailable
                                      ? () {
                                          widget.onAdd(item);
                                          setState(() => _cartCount++);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              duration: const Duration(
                                                milliseconds: 900,
                                              ),
                                              content: Text(
                                                'เพิ่ม ${item.name} แล้ว',
                                              ),
                                            ),
                                          );
                                        }
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
        ],
      ),
    );
  }
}
