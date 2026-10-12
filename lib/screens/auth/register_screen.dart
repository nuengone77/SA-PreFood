import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// ฟอร์มสมัครสมาชิกแบบ mock รองรับทั้งลูกค้าและร้านค้า
/// เมื่อเลือกบทบาทร้านค้า ระบบจะแสดงช่องชื่อร้านและประเภทอาหารเพิ่มขึ้น
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.initialRole = AppRole.customer});
  final AppRole initialRole;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // เก็บบทบาทปัจจุบันเพื่อสลับชุดช่องกรอกข้อมูลด้วย setState
  late AppRole _role;
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  /// ตรวจช่องบังคับทั้งหมดก่อนสร้างบัญชี
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _role == AppRole.vendor
              ? 'ส่งคำขอเปิดร้านแล้ว รอผู้ดูแลระบบอนุมัติ'
              : 'สร้างบัญชีสำเร็จ',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    // Admin ไม่มีขั้นตอนสมัครสมาชิก จึง fallback เป็นลูกค้าหากถูกส่งเข้ามา
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
            child: Form(
              key: _formKey,
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
                    'กรอกข้อมูลให้ครบทุกช่องเพื่อสร้างบัญชี',
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
                    _field('ชื่อร้าน', Icons.storefront_outlined),
                    _field('ประเภทอาหาร', Icons.category_outlined),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          isVendor ? 'ชื่อผู้ดูแลร้าน' : 'ชื่อ',
                          Icons.badge_outlined,
                          key: const Key('reg-first-name'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _field('นามสกุล', Icons.badge_outlined)),
                    ],
                  ),
                  if (!isVendor)
                    _field(
                      'รหัสนิสิต/รหัสบุคลากร',
                      Icons.school_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  _field(
                    'หมายเลขโทรศัพท์',
                    Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: phoneField,
                  ),
                  _field('ชื่อผู้ใช้', Icons.alternate_email_rounded),
                  _field(
                    'รหัสผ่าน',
                    Icons.lock_outline_rounded,
                    controller: _password,
                    obscure: true,
                    validator: (value) => (value ?? '').length < 8
                        ? 'รหัสผ่านอย่างน้อย 8 ตัวอักษร'
                        : null,
                  ),
                  _field(
                    'ยืนยันรหัสผ่าน',
                    Icons.lock_reset_rounded,
                    obscure: true,
                    validator: (value) =>
                        value != _password.text ? 'รหัสผ่านไม่ตรงกัน' : null,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('register-submit'),
                      onPressed: _submit,
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
      ),
    );
  }

  /// ช่องกรอกมาตรฐานของฟอร์มสมัครสมาชิก ทุกช่องเป็นช่องบังคับ
  Widget _field(
    String label,
    IconData icon, {
    Key? key,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool obscure = false,
    FormFieldValidator<String>? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      key: key,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator ?? requiredField,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    ),
  );
}
