import 'package:flutter/material.dart';

import '../../app_store.dart';
import '../../widgets/common_widgets.dart';

/// หน้าแก้ไขข้อมูลส่วนตัวของลูกค้า (รายงานข้อ 2.3.1)
/// ชื่อผู้ใช้ใช้สำหรับเข้าสู่ระบบจึงแก้ไขไม่ได้
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profile = appStore.profile;
  late final _firstName = TextEditingController(text: _profile.firstName);
  late final _lastName = TextEditingController(text: _profile.lastName);
  late final _studentId = TextEditingController(text: _profile.studentStaffId);
  late final _phone = TextEditingController(text: _profile.phone);

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _studentId.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    appStore.updateProfile(
      UserProfile(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        studentStaffId: _studentId.text.trim(),
        phone: _phone.text.trim(),
        username: _profile.username,
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลส่วนตัวแล้ว')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'แก้ไขข้อมูลส่วนตัว',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
          children: [
            TextFormField(
              controller: _firstName,
              validator: requiredField,
              decoration: const InputDecoration(
                labelText: 'ชื่อ',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _lastName,
              validator: requiredField,
              decoration: const InputDecoration(
                labelText: 'นามสกุล',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _studentId,
              validator: requiredField,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'รหัสนิสิต/รหัสบุคลากร',
                prefixIcon: Icon(Icons.school_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              validator: phoneField,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'หมายเลขโทรศัพท์',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: _profile.username,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'ชื่อผู้ใช้',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _save,
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}
