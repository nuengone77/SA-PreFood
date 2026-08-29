import 'package:flutter/material.dart';

import '../../models/models.dart';

class MenuFormScreen extends StatefulWidget {
  const MenuFormScreen({super.key, this.item});
  final FoodItem? item;

  @override
  State<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends State<MenuFormScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.item?.name ?? '',
  );
  late final TextEditingController _price = TextEditingController(
    text: widget.item?.price.toStringAsFixed(0) ?? '',
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.item?.description ?? '',
  );
  String _category = 'จานหลัก';

  @override
  void initState() {
    super.initState();
    _category = widget.item?.category ?? 'จานหลัก';
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.item != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing ? 'แก้ไขเมนู' : 'เพิ่มเมนูใหม่',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE1C5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF0D2B7)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.item?.emoji ?? '📷',
                  style: const TextStyle(fontSize: 52),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('เลือกภาพตัวอย่างแล้ว')),
                  ),
                  icon: const Icon(Icons.upload_rounded),
                  label: const Text('เลือกรูปภาพ'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'ชื่อเมนู',
              prefixIcon: Icon(Icons.restaurant_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'ราคา',
              prefixIcon: Icon(Icons.payments_outlined),
              suffixText: 'บาท',
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'หมวดหมู่',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: ['จานหลัก', 'เส้น', 'ของหวาน', 'เครื่องดื่ม']
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'คำอธิบาย',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              final name = _name.text.trim().isEmpty
                  ? 'เมนูใหม่'
                  : _name.text.trim();
              Navigator.pop(
                context,
                FoodItem(
                  id:
                      widget.item?.id ??
                      'new-${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  description: _description.text.trim().isEmpty
                      ? 'เมนูอร่อยประจำร้าน'
                      : _description.text.trim(),
                  category: _category,
                  price: double.tryParse(_price.text) ?? 50,
                  emoji: widget.item?.emoji ?? '🍽️',
                  color: widget.item?.color ?? const Color(0xFFFFE1C5),
                  isAvailable: widget.item?.isAvailable ?? true,
                ),
              );
            },
            child: Text(editing ? 'บันทึกการแก้ไข' : 'เพิ่มเมนู'),
          ),
        ],
      ),
    );
  }
}
