import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'โรงอาหารของคุณ • ไม่ต้องรอคิว',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 238,
                    height: 238,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.orange.withValues(alpha: .10),
                    ),
                  ),
                  Container(
                    width: 176,
                    height: 176,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.green.withValues(alpha: .08),
                    ),
                  ),
                  const BrandMark(size: 110),
                  const Positioned(
                    top: 8,
                    right: 30,
                    child: Text('🥗', style: TextStyle(fontSize: 42)),
                  ),
                  const Positioned(
                    bottom: 12,
                    left: 28,
                    child: Text('🥤', style: TextStyle(fontSize: 38)),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Text(
                'PreFood',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'สั่งก่อน อร่อยได้ตรงเวลา',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.orangeDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'เลือกเมนูโปรดล่วงหน้า แล้วไปรับเมื่อพร้อม\nประหยัดเวลาพัก ให้ทุกมื้อเป็นเรื่องง่าย',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, height: 1.55),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('welcome-login'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  iconAlignment: IconAlignment.end,
                  label: const Text('เข้าสู่ระบบ'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Prototype • Mock data only',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
