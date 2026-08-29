import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = '7 วัน';

  @override
  Widget build(BuildContext context) {
    const sales = [.42, .62, .51, .88, .7, 1.0, .79];
    const days = ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'สรุปยอดขาย',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '7 วัน', label: Text('7 วัน')),
                ButtonSegment(value: '30 วัน', label: Text('30 วัน')),
              ],
              selected: {_period},
              onSelectionChanged: (value) =>
                  setState(() => _period = value.first),
              showSelectedIcon: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ยอดขายรวม',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 5),
                Text(
                  _period == '7 วัน' ? '฿42,580' : '฿168,420',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  '↑ 12.4% จากช่วงก่อนหน้า',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      sales.length,
                      (index) => Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: sales[index],
                                  child: Container(
                                    width: 25,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.orange,
                                          Color(0xFFFFB083),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              days[index],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'ร้านค้ายอดนิยม',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: const [
              _RankTile(
                rank: 1,
                emoji: '🍳',
                name: 'ครัวป้าแดง',
                orders: '326 ออเดอร์',
                sales: '฿18,420',
              ),
              Divider(height: 1, indent: 62),
              _RankTile(
                rank: 2,
                emoji: '🍜',
                name: 'บ้านเส้น',
                orders: '284 ออเดอร์',
                sales: '฿15,860',
              ),
              Divider(height: 1, indent: 62),
              _RankTile(
                rank: 3,
                emoji: '🍧',
                name: 'หวานใจ',
                orders: '241 ออเดอร์',
                sales: '฿12,240',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('สร้างรายงานตัวอย่างเรียบร้อย')),
          ),
          icon: const Icon(Icons.download_rounded),
          label: const Text('ดาวน์โหลดรายงาน'),
        ),
      ],
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({
    required this.rank,
    required this.emoji,
    required this.name,
    required this.orders,
    required this.sales,
  });
  final int rank;
  final String emoji;
  final String name;
  final String orders;
  final String sales;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
    leading: Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          backgroundColor: AppColors.cream,
          child: Text(emoji, style: const TextStyle(fontSize: 23)),
        ),
        Positioned(
          left: -7,
          top: -6,
          child: CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.orange,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    ),
    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
    subtitle: Text(
      orders,
      style: const TextStyle(color: AppColors.muted, fontSize: 12),
    ),
    trailing: Text(sales, style: const TextStyle(fontWeight: FontWeight.w900)),
  );
}
