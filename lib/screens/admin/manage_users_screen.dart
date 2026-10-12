import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// หน้าจัดการผู้ใช้ ให้ Admin เปิดใช้งานหรือระงับบัญชีตัวอย่าง
class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  // รายการ local state สำหรับจำลองการเปลี่ยนสถานะโดยไม่ใช้ฐานข้อมูล
  final users = <_UserRecord>[
    _UserRecord('ธนกร ใจดี', '@thanakorn • 67312345', 'ลูกค้า', true),
    _UserRecord('มินตรา สุขใจ', '@mintra • 67318890', 'ลูกค้า', true),
    _UserRecord('สมชาย แสงดี', '@somchai • 089-123-4567', 'ร้านค้า', true),
    _UserRecord('บัญชีทดสอบ', '@demo • 67300000', 'ลูกค้า', false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'ค้นหาชื่อ ชื่อผู้ใช้ หรือรหัสนิสิต',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 16),
        ...users.map(
          (user) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                leading: CircleAvatar(
                  backgroundColor:
                      (user.active ? AppColors.green : AppColors.muted)
                          .withValues(alpha: .12),
                  child: Icon(
                    Icons.person_rounded,
                    color: user.active ? AppColors.green : AppColors.muted,
                  ),
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    '${user.account}\n${user.role}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (_) => setState(() => user.active = !user.active),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: ListTile(
                        leading: Icon(
                          user.active
                              ? Icons.block_rounded
                              : Icons.restore_rounded,
                        ),
                        title: Text(user.active ? 'ระงับบัญชี' : 'เปิดบัญชี'),
                      ),
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

/// โมเดลผู้ใช้แบบย่อที่ใช้เฉพาะในหน้าจัดการผู้ใช้
class _UserRecord {
  _UserRecord(this.name, this.account, this.role, this.active);
  final String name;
  final String account;
  final String role;
  bool active;
}
