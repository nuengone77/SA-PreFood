import 'package:flutter/material.dart';

import '../../app_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../auth/splash_screen.dart';
import 'edit_profile_screen.dart';

/// หน้าโปรไฟล์ลูกค้า แสดงข้อมูลบัญชีและเมนูตั้งค่าตัวอย่าง
class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  // สถานะเปิด/ปิดการแจ้งเตือนในหน้าโปรไฟล์
  bool _notificationsEnabled = true;

  void _openEdit(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final profile = appStore.profile;
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${profile.username}',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                        Text(
                          'โทร ${profile.phone}',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'รหัสนิสิต/บุคลากร ${profile.studentStaffId}',
                          style: const TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('edit-profile'),
                    tooltip: 'แก้ไขข้อมูลส่วนตัว',
                    onPressed: () => _openEdit(context),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const PointsBalanceCard(),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _ProfileTile(
                  icon: Icons.badge_outlined,
                  title: 'ข้อมูลส่วนตัว',
                  onTap: () => _openEdit(context),
                ),
                const Divider(height: 1, indent: 60),
                _ProfileTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'การแจ้งเตือน',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) =>
                        setState(() => _notificationsEnabled = value),
                  ),
                  onTap: () => setState(
                    () => _notificationsEnabled = !_notificationsEnabled,
                  ),
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

/// การ์ดแสดงแต้มสะสมคงเหลือ ใช้ในหน้าโปรไฟล์และประวัติการสั่งซื้อ
class PointsBalanceCard extends StatelessWidget {
  const PointsBalanceCard({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: appStore,
    builder: (context, _) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB33A), Color(0xFFF47C48)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('แต้มสะสม', style: TextStyle(color: Colors.white)),
                Text(
                  '${appStore.points} แต้ม',
                  key: const Key('points-balance'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'ทุก ฿${AppStore.bahtPerPoint} = 1 แต้ม\n1 แต้ม = ส่วนลด ฿1',
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
