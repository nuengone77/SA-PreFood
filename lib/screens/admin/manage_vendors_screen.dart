import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// หน้าจัดการร้านค้า ให้ Admin อนุมัติ ระงับ หรือเปิดใช้งานร้าน
class ManageVendorsScreen extends StatefulWidget {
  const ManageVendorsScreen({super.key});

  @override
  State<ManageVendorsScreen> createState() => _ManageVendorsScreenState();
}

class _ManageVendorsScreenState extends State<ManageVendorsScreen> {
  // รายการ mutable แบบ local เพื่อให้สถานะเปลี่ยนทันทีเมื่อเลือกคำสั่ง
  final vendors = <_VendorRecord>[
    _VendorRecord('ข้าวมันไก่คุณยาย', 'อาหารจานเดียว', '🍗', 'รออนุมัติ'),
    _VendorRecord('ครัวป้าแดง', 'อาหารตามสั่ง', '🍳', 'เปิดใช้งาน'),
    _VendorRecord('บ้านเส้น', 'ก๋วยเตี๋ยว', '🍜', 'เปิดใช้งาน'),
    _VendorRecord('Daily Brew', 'เครื่องดื่ม', '🥤', 'ระงับชั่วคราว'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'ค้นหาชื่อร้าน',
            prefixIcon: Icon(Icons.search_rounded),
            suffixIcon: Icon(Icons.tune_rounded),
          ),
        ),
        const SizedBox(height: 16),
        ...vendors.map(
          (vendor) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: .11),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        vendor.emoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendor.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            vendor.category,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 7),
                          StatusPill(
                            label: vendor.status,
                            color: vendor.status == 'เปิดใช้งาน'
                                ? AppColors.green
                                : vendor.status == 'รออนุมัติ'
                                ? AppColors.orange
                                : Colors.red.shade500,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (action) => setState(() {
                        if (action == 'approve') {
                          vendor.status = 'เปิดใช้งาน';
                        }
                        if (action == 'suspend') {
                          vendor.status = 'ระงับชั่วคราว';
                        }
                      }),
                      itemBuilder: (_) => [
                        if (vendor.status == 'รออนุมัติ')
                          const PopupMenuItem(
                            value: 'approve',
                            child: ListTile(
                              leading: Icon(
                                Icons.check_circle_outline,
                                color: AppColors.green,
                              ),
                              title: Text('อนุมัติ'),
                            ),
                          ),
                        PopupMenuItem(
                          value: vendor.status == 'เปิดใช้งาน'
                              ? 'suspend'
                              : 'approve',
                          child: ListTile(
                            leading: Icon(
                              vendor.status == 'เปิดใช้งาน'
                                  ? Icons.block_rounded
                                  : Icons.restore_rounded,
                            ),
                            title: Text(
                              vendor.status == 'เปิดใช้งาน'
                                  ? 'ระงับร้าน'
                                  : 'เปิดใช้งาน',
                            ),
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
    );
  }
}

/// โมเดลภายในหน้าจอสำหรับเก็บสถานะร้านที่แก้ไขได้ใน prototype
class _VendorRecord {
  _VendorRecord(this.name, this.category, this.emoji, this.status);
  final String name;
  final String category;
  final String emoji;
  String status;
}
