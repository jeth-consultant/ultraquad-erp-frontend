import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/placeholder_screen.dart';

/// First screen shown to a signed-out user: branding, tagline, feature
/// highlights, and entry points to create an account or sign in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _Logo(),
              const SizedBox(height: 24),
              Text(
                'UltraQuad ERP',
                style: AppTextStyles.heading1.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Team accountability made simple. Track monthly Paybill '
                'contributions, daily GitHub pushes, and automate fines — '
                'all in one place.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _FeatureGrid(),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PlaceholderScreen(title: 'Create account'),
                      ),
                    );
                  },
                  child: const Text('Create account', style: AppTextStyles.button),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PlaceholderScreen(title: 'Sign in'),
                      ),
                    );
                  },
                  child: Text(
                    'Sign in',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.caption,
                    children: [
                      const TextSpan(text: 'Already part of a team? '),
                      TextSpan(
                        text: 'Join with your organization Paybill.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PlaceholderScreen(title: 'Join organization'),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.bolt, color: Colors.white, size: 36),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    const features = [
      _FeatureBadgeData(icon: Icons.link, label: 'Contributions'),
      _FeatureBadgeData(icon: Icons.account_tree_outlined, label: 'GitHub Sync'),
      _FeatureBadgeData(icon: Icons.notifications_active_outlined, label: 'Auto Fines'),
      _FeatureBadgeData(icon: Icons.shield_outlined, label: 'M-Pesa Paybill'),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: features.map((f) => _FeatureBadge(data: f)).toList(),
    );
  }
}

class _FeatureBadgeData {
  const _FeatureBadgeData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({required this.data});

  final _FeatureBadgeData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(data.label, style: AppTextStyles.body.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}
