import 'package:flutter/material.dart';

import '../../app_store.dart';
import '../../mock_data.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// รายงานสรุปยอดขายของร้านค้า (รายงานข้อ 2.1.5, 2.3.9 และ Use case 9)
/// เลือกดูได้ทั้งรายวัน รายสัปดาห์ และรายเดือน แสดงจำนวนออเดอร์ ยอดขายรวม และเมนูขายดี
class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  SalesPeriod _period = SalesPeriod.daily;

  @override
  Widget build(BuildContext context) {
    final summary = vendorSalesReport[_period]!;
    final maxSold = summary.bestSellers.first.$3;
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          const PageIntro(
            title: 'รายงานยอดขาย',
            subtitle: 'สรุปยอดขายและเมนูขายดีของร้าน',
          ),
          const SizedBox(height: 18),
          SegmentedButton<SalesPeriod>(
            segments: SalesPeriod.values
                .map(
                  (period) =>
                      ButtonSegment(value: period, label: Text(period.label)),
                )
                .toList(),
            selected: {_period},
            onSelectionChanged: (value) =>
                setState(() => _period = value.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  icon: Icons.payments_outlined,
                  label: 'ยอดขายรวม',
                  value: '฿${_formatNumber(summary.revenue.round())}',
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Metric(
                  icon: Icons.receipt_long_rounded,
                  label: 'จำนวนออเดอร์',
                  value: _formatNumber(summary.orders),
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _MoneyRow(label: 'ยอดขายรวม', value: summary.revenue),
                  _MoneyRow(
                    label: 'ค่าธรรมเนียม PreFood ${PlatformConfig.feePercent}%',
                    value: -PlatformConfig.feeFor(summary.revenue),
                  ),
                  const Divider(height: 20),
                  _MoneyRow(
                    label: 'ยอดที่ได้รับจาก PreFood',
                    value:
                        summary.revenue -
                        PlatformConfig.feeFor(summary.revenue),
                    emphasized: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'เมนูขายดี',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final (index, (name, emoji, sold))
                      in summary.bestSellers.indexed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.orangeDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(emoji, style: const TextStyle(fontSize: 26)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: sold / maxSold,
                                    minHeight: 7,
                                    backgroundColor: AppColors.cream,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$sold จาน',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const _PayoutSection(),
        ],
      ),
    );
  }
}

/// ใส่จุลภาคคั่นหลักพัน เช่น 18420 -> 18,420
String _formatNumber(int value) => value.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);

/// แถวจำนวนเงิน ค่าติดลบแสดงเป็นรายการหัก
class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });
  final String label;
  final double value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? AppColors.ink : AppColors.muted,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          '${value < 0 ? '-' : ''}฿${_formatNumber(value.abs().round())}',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: emphasized ? 18 : 14,
            color: emphasized
                ? AppColors.green
                : value < 0
                ? Colors.red.shade500
                : AppColors.ink,
          ),
        ),
      ],
    ),
  );
}

/// การ์ดตัวเลขสรุปหนึ่งค่า
class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          Text(label, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    ),
  );
}

/// การโอนเงินจาก PreFood ให้ร้าน รวมยอดทั้งเดือนแล้วโอนครั้งเดียวในเดือนถัดไป
class _PayoutSection extends StatelessWidget {
  const _PayoutSection();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final monthly = vendorSalesReport[SalesPeriod.monthly]!.revenue;
    final pending = monthly - PlatformConfig.feeFor(monthly);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'การโอนเงินจาก PreFood',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _PayoutTile(month: thisMonth, amount: pending, paid: false),
              for (final (i, amount) in vendorPastPayouts.indexed) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                _PayoutTile(
                  month: DateTime(thisMonth.year, thisMonth.month - i - 1),
                  amount: amount,
                  paid: true,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'PreFood รวมยอดขายทั้งเดือน หักค่าธรรมเนียม ${PlatformConfig.feePercent}% '
          'แล้วโอนเข้าบัญชี ${appStore.vendorShop.bankAccount} '
          'ทุกวันที่ ${PlatformConfig.payoutDay} ของเดือนถัดไป',
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}

/// ยอดโอนหนึ่งเดือน
class _PayoutTile extends StatelessWidget {
  const _PayoutTile({
    required this.month,
    required this.amount,
    required this.paid,
  });
  final DateTime month;
  final double amount;
  final bool paid;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(
      'ยอดเดือน ${formatThaiMonthYear(month)}',
      style: const TextStyle(fontWeight: FontWeight.w800),
    ),
    subtitle: Text(
      '${paid ? 'โอนแล้ว' : 'กำหนดโอน'} '
      '${formatThaiDate(PlatformConfig.payoutDateFor(month))}',
    ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '฿${_formatNumber(amount.round())}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 4),
        StatusPill(
          label: paid ? 'โอนแล้ว' : 'สะสมยอด',
          color: paid ? AppColors.green : AppColors.orange,
        ),
      ],
    ),
  );
}
