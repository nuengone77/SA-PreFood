import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../auth/splash_screen.dart';

/// หน้าโปรไฟล์ลูกค้า แสดงข้อมูลบัญชีและเมนูตั้งค่าตัวอย่าง
class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          const PageIntro(
            title: 'โปรไฟล์',
            subtitle: 'จัดการข้อมูลและการตั้งค่าบัญชี',
          ),
          const SizedBox(height: 22),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: .14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 42,
                      color: AppColors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ธนกร ใจดี',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'thanakorn@university.ac.th',
                          style: TextStyle(color: AppColors.muted),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'ลูกค้า • นักศึกษา',
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _ProfileTile(
                  icon: Icons.badge_outlined,
                  title: 'ข้อมูลส่วนตัว',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 60),
                _ProfileTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'การแจ้งเตือน',
                  trailing: Switch(value: true, onChanged: (_) {}),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 60),
                _ProfileTile(
                  icon: Icons.help_outline_rounded,
                  title: 'ช่วยเหลือและติดต่อเรา',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SplashScreen()),
              (_) => false,
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('ออกจากระบบ'),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'PreFood v1.0.0 • UI Prototype',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// ListTile รูปแบบกลางสำหรับเมนูย่อยภายในหน้าโปรไฟล์
class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    leading: Icon(icon, color: AppColors.orangeDark),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}
