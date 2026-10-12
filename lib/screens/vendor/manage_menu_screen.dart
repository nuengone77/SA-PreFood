import 'package:flutter/material.dart';

import '../../app_store.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'menu_form_screen.dart';

/// หน้าจัดการเมนูของร้านค้า รองรับเพิ่ม แก้ไข ลบ และตั้งสถานะวัตถุดิบ (มีสินค้า/สินค้าหมด)
/// บันทึกลง [appStore] ฝั่งลูกค้าจึงเห็นสถานะสินค้าหมดทันที
class ManageMenuScreen extends StatefulWidget {
  const ManageMenuScreen({super.key});

  @override
  State<ManageMenuScreen> createState() => _ManageMenuScreenState();
}

class _ManageMenuScreenState extends State<ManageMenuScreen> {
  static const _shopId = AppStore.vendorShopId;

  /// เปิดฟอร์มในโหมดเพิ่มหรือแก้ไข แล้วบันทึก FoodItem ที่ได้กลับมา
  Future<void> _openForm([FoodItem? item]) async {
    final result = await Navigator.push<FoodItem>(
      context,
      MaterialPageRoute(builder: (_) => MenuFormScreen(item: item)),
    );
    if (result == null) return;
    appStore.saveMenuItem(_shopId, result);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final items = appStore.vendorShop.menu;
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 90),
        children: [
          PageIntro(
            title: 'จัดการเมนู',
            subtitle:
                '${items.where((item) => item.isAvailable).length}/${items.length} เมนูมีสินค้า',
            trailing: IconButton.filled(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add_rounded),
              tooltip: 'เพิ่มเมนู',
            ),
          ),
          const SizedBox(height: 18),
          ...items.map(
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
                        height: 82,
                        width: 82,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.category} • ฿${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  item.stockLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: item.isAvailable
                                        ? AppColors.green
                                        : Colors.red.shade500,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Switch(
                                  value: item.isAvailable,
                                  onChanged: (value) => appStore.saveMenuItem(
                                    _shopId,
                                    item.copyWith(isAvailable: value),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openForm(item);
                          }
                          if (value == 'delete') {
                            appStore.deleteMenuItem(_shopId, item);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('แก้ไข'),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              title: Text('ลบ'),
                            ),
                          ),
                        ],
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
