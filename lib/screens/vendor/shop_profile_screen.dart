import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../auth/splash_screen.dart';

/// หน้าโปรไฟล์ร้าน แสดงข้อมูลติดต่อ เวลาเปิดปิด และสถานะร้าน
class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  // สถานะเปิดร้านแบบ local สำหรับสาธิตการใช้งาน Switch
  bool _isOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'โปรไฟล์ร้าน',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFDCCB),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('🍳', style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'ครัวป้าแดง',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'อาหารตามสั่ง • โรงอาหารกลาง ล็อก A03',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 14),
                  StatusButton(
                    isOpen: _isOpen,
                    onChanged: (value) => setState(() => _isOpen = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(
                    Icons.schedule_outlined,
                    color: AppColors.orange,
                  ),
                  title: Text('เวลาเปิด-ปิด'),
                  subtitle: Text('จันทร์-ศุกร์ 08:00–16:30'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
                Divider(height: 1, indent: 60),
                ListTile(
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.orange,
                  ),
                  title: Text('ตำแหน่งร้าน'),
                  subtitle: Text('โรงอาหารกลาง ล็อก A03'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
                Divider(height: 1, indent: 60),
                ListTile(
                  leading: Icon(Icons.call_outlined, color: AppColors.orange),
                  title: Text('เบอร์ติดต่อ'),
                  subtitle: Text('089-123-4567'),
                  trailing: Icon(Icons.chevron_right_rounded),
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
        ],
      ),
    );
  }
}

/// กล่องควบคุมสถานะเปิด/ปิดร้านที่แสดงข้อความและ Switch คู่กัน
class StatusButton extends StatelessWidget {
  const StatusButton({
    super.key,
    required this.isOpen,
    required this.onChanged,
  });
  final bool isOpen;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(
      color: (isOpen ? AppColors.green : AppColors.muted).withValues(alpha: .1),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isOpen ? 'ร้านเปิดอยู่' : 'ร้านปิดอยู่',
          style: TextStyle(
            color: isOpen ? AppColors.green : AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
        Switch(value: isOpen, onChanged: onChanged),
      ],
    ),
  );
}
