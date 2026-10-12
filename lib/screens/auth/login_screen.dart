import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../admin/admin_shell.dart';
import '../customer/customer_shell.dart';
import '../vendor/vendor_shell.dart';
import 'register_screen.dart';

/// หน้าเข้าสู่ระบบแบบ mock ให้เลือกบทบาทก่อนเข้าสู่หน้าหลัก
/// ช่องอีเมลและรหัสผ่านมีไว้แสดง UX เท่านั้น จึงยังไม่ตรวจสอบข้อมูลจริง
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // บทบาทที่เลือกและสถานะการซ่อน/แสดงรหัสผ่านบนหน้าจอ
  AppRole _role = AppRole.customer;
  bool _obscure = true;

  /// เลือก shell ปลายทางตาม role แล้วล้างหน้า Auth ออกจาก navigation stack
  /// เพื่อไม่ให้กด Back แล้วกลับมาหน้า Login หลังเข้าสู่ระบบ
  void _login() {
    final destination = switch (_role) {
      AppRole.customer => const CustomerShell(),
      AppRole.vendor => const VendorShell(),
      AppRole.admin => const AdminShell(),
    };
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandMark(size: 64),
                  const SizedBox(height: 24),
                  Text(
                    'จองอาหารต้อง PreFood',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'เลือกประเภทบัญชี แล้วเข้าสู่ระบบเพื่อเริ่มใช้งาน',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: AppRole.values.map((role) {
                        final selected = role == _role;
                        return Expanded(
                          child: InkWell(
                            key: Key('role-${role.name}'),
                            onTap: () => setState(() => _role = role),
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.orange
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    role.icon,
                                    size: 20,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.muted,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    role.label,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    key: const Key('login-email'),
                    decoration: const InputDecoration(
                      labelText: 'ชื่อผู้ใช้',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'รหัสผ่าน',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          _showDemoMessage('ระบบจะส่งลิงก์ตั้งรหัสผ่านใหม่'),
                      child: const Text('ลืมรหัสผ่าน?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('login-submit'),
                      onPressed: _login,
                      child: Text('เข้าสู่ระบบในฐานะ${_role.label}'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_role != AppRole.admin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ยังไม่มีบัญชี?',
                          style: TextStyle(color: AppColors.muted),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegisterScreen(initialRole: _role),
                            ),
                          ),
                          child: const Text('สมัครสมาชิก'),
                        ),
                      ],
                    )
                  else
                    const Center(
                      child: Text(
                        'บัญชี Admin ใช้ข้อมูลที่ระบบกำหนดไว้',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// แสดง SnackBar แทนการทำงานจริงของฟีเจอร์ที่ยังเป็น prototype
  void _showDemoMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$message (โหมดตัวอย่าง)')));
  }
}
