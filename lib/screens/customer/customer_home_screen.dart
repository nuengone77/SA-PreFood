import 'package:flutter/material.dart';

import '../../app_store.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// หน้าค้นหาร้านของลูกค้า รองรับการค้นหาด้วยข้อความและกรองหมวดหมู่
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key, required this.onOpenShop});
  final ValueChanged<Shop> onOpenShop;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  // ค่า filter ปัจจุบัน ใช้คำนวณรายการร้านใหม่ทุกครั้งที่ build
  String _category = 'ทั้งหมด';
  String _query = '';
  static const categories = [
    'ทั้งหมด',
    'อาหารตามสั่ง',
    'ก๋วยเตี๋ยว',
    'ของหวาน',
    'เครื่องดื่ม',
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) => _build(context),
    );
  }

  /// เมนูของร้านที่ชื่อตรงกับคำค้น ใช้แสดงใต้การ์ดร้าน
  List<FoodItem> _matchedMenu(Shop shop) {
    if (_query.isEmpty) return const [];
    final query = _query.toLowerCase();
    return shop.menu
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  Widget _build(BuildContext context) {
    // กรองร้านจากหมวดหมู่ และคำค้นที่ตรงกับชื่อร้าน ประเภทอาหาร หรือชื่อเมนู
    final shops = appStore.shops.where((shop) {
      final categoryMatches =
          _category == 'ทั้งหมด' || shop.category == _category;
      final queryMatches =
          _query.isEmpty ||
          shop.name.toLowerCase().contains(_query.toLowerCase()) ||
          shop.category.contains(_query) ||
          _matchedMenu(shop).isNotEmpty;
      return categoryMatches && queryMatches;
    }).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            sliver: SliverList.list(
              children: [
                PageIntro(
                  title: 'หิวอะไรดีวันนี้?',
                  subtitle: 'โรงอาหารกลาง • เปิดถึง 16:30',
                  trailing: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.orange, Color(0xFFFFA05F)],
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
                              'พักเที่ยงไม่ต้องรอคิว',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'สั่งล่วงหน้า แล้วรับได้เลย',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .88),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text('🍱', style: TextStyle(fontSize: 52)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'ค้นหาร้าน เมนู หรือประเภทอาหาร',
                    prefixIcon: Icon(Icons.search_rounded),
                    suffixIcon: Icon(Icons.tune_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, index) {
                      final category = categories[index];
                      return ChoiceChip(
                        label: Text(category),
                        selected: category == _category,
                        onSelected: (_) => setState(() => _category = category),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Text(
                      'ร้านแนะนำ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${shops.length} ร้าน',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          if (shops.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'ไม่พบร้านที่ค้นหา',
                message: 'ลองเปลี่ยนคำค้นหาหรือหมวดหมู่',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.crossAxisExtent >= 1050
                      ? 3
                      : constraints.crossAxisExtent >= 640
                      ? 2
                      : 1;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisExtent: 162,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => _ShopCard(
                        shop: shops[index],
                        matchedMenu: _matchedMenu(shops[index]),
                        onTap: () => widget.onOpenShop(shops[index]),
                      ),
                      childCount: shops.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// การ์ดร้านค้าหนึ่งร้าน แสดงสถานะ คะแนน และเวลารอโดยประมาณ
class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.shop,
    required this.onTap,
    this.matchedMenu = const [],
  });
  final Shop shop;

  /// เมนูที่ตรงกับคำค้น ถ้ามีจะแสดงแทนคำอธิบายร้าน
  final List<FoodItem> matchedMenu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: shop.isOpen ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              EmojiVisual(
                emoji: shop.emoji,
                color: shop.color,
                height: 136,
                width: 122,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shop.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        StatusPill(
                          label: shop.isOpen ? 'เปิด' : 'ปิด',
                          color: shop.isOpen
                              ? AppColors.green
                              : AppColors.muted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      shop.category,
                      style: const TextStyle(
                        color: AppColors.orangeDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      matchedMenu.isEmpty
                          ? shop.description
                          : 'พบเมนู: ${matchedMenu.map((e) => e.name).join(', ')}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB33A),
                          size: 18,
                        ),
                        Text(
                          ' ${shop.rating}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.schedule_rounded,
                          color: AppColors.muted,
                          size: 16,
                        ),
                        Text(
                          ' ${shop.waitMinutes} นาที',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
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
      ),
    );
  }
}
