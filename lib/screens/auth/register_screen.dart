import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.initialRole = AppRole.customer});
  final AppRole initialRole;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late AppRole _role;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole == AppRole.admin
        ? AppRole.customer
        : widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    final isVendor = _role == AppRole.vendor;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'สร้างบัญชี',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVendor ? 'เปิดร้านกับ PreFood' : 'เริ่มสั่งอาหารได้เลย',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'กรอกข้อมูลเบื้องต้นเพื่อสร้างบัญชีตัวอย่าง',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 20),
                SegmentedButton<AppRole>(
                  segments: const [
                    ButtonSegment(
                      value: AppRole.customer,
                      icon: Icon(Icons.person_outline),
                      label: Text('ลูกค้า'),
                    ),
                    ButtonSegment(
                      value: AppRole.vendor,
                      icon: Icon(Icons.storefront_outlined),
                      label: Text('ร้านค้า'),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (value) =>
                      setState(() => _role = value.first),
                  showSelectedIcon: false,
                ),
                const SizedBox(height: 20),
                if (isVendor) ...[
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'ชื่อร้าน',
                      prefixIcon: Icon(Icons.storefront_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'ประเภทอาหาร',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                TextField(
                  decoration: InputDecoration(
                    labelText: isVendor ? 'ชื่อผู้ดูแลร้าน' : 'ชื่อ-นามสกุล',
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                const TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'ยืนยันรหัสผ่าน',
                    prefixIcon: Icon(Icons.lock_reset_rounded),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('สร้างบัญชีตัวอย่างสำเร็จ'),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: Text(isVendor ? 'ส่งคำขอเปิดร้าน' : 'สมัครสมาชิก'),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'เมื่อดำเนินการต่อ ถือว่าคุณยอมรับข้อกำหนดและนโยบายความเป็นส่วนตัว',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
