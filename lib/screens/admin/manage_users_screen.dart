import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final users = <_UserRecord>[
    _UserRecord('ธนกร ใจดี', 'thanakorn@university.ac.th', 'ลูกค้า', true),
    _UserRecord('มินตรา สุขใจ', 'mintra@university.ac.th', 'ลูกค้า', true),
    _UserRecord('สมชาย แสงดี', 'somchai@shop.co', 'ร้านค้า', true),
    _UserRecord('บัญชีทดสอบ', 'demo@university.ac.th', 'ลูกค้า', false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'ค้นหาชื่อหรืออีเมล',
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
                    '${user.email}\n${user.role}',
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

class _UserRecord {
  _UserRecord(this.name, this.email, this.role, this.active);
  final String name;
  final String email;
  final String role;
  bool active;
}
