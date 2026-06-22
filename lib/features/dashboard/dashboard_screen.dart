import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/navigation/app_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/relative_time.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/soft_card.dart';
import '../auth/providers/auth_provider.dart';
import '../contributions/contributions_screen.dart';
import '../contributions/providers/contributions_provider.dart';
import '../fines/fines_screen.dart';
import '../fines/providers/fines_provider.dart';
import '../notifications/models/app_notification.dart';
import '../notifications/notifications_screen.dart';
import '../notifications/providers/notifications_provider.dart';
import '../payments/payment_screen.dart';
import '../push_days/push_days_screen.dart';
import '../push_days/providers/push_days_provider.dart';
import 'dashboard_stats.dart';

class _Tip {
  const _Tip(this.text, this.actionLabel, this.section, this.screenBuilder);
  final String text;
  final String actionLabel;
  final AppSection section;
  final Widget Function() screenBuilder;
}

final _tips = [
  _Tip("Pay your contribution early in the month and you'll dodge the late-payment fine entirely.", 'Make a payment',
      AppSection.payments, () => const PaymentScreen()),
  _Tip('A paid fine today is a clean slate tomorrow — small amounts add up fast if left unpaid.', 'View fines',
      AppSection.fines, () => const FinesScreen()),
  _Tip("Consistency beats intensity. A small push every day keeps your streak alive.", 'View push days',
      AppSection.pushDays, () => const PushDaysScreen()),
  _Tip('Keep an eye on notifications so you never miss a fine or a reminder.', 'View notifications',
      AppSection.notifications, () => const NotificationsScreen()),
];

/// Home screen shown after login: a personal greeting, real stats pulled
/// from the contributions/fines/push-days endpoints, recent activity
/// drawn from notifications, and quick actions. Full navigation lives in
/// the sidebar drawer.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fullName = ref.watch(authProvider).fullName ?? 'there';
    final firstName = fullName.split(' ').first;

    final contributions = ref.watch(contributionsProvider).valueOrNull ?? const [];
    final fines = ref.watch(finesProvider).valueOrNull ?? const [];
    final pushDays = ref.watch(pushDaysProvider).valueOrNull ?? const [];
    final notifications = ref.watch(notificationsProvider).valueOrNull ?? const [];
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final stats = DashboardStats.compute(contributions: contributions, fines: fines, pushDays: pushDays);

    final tip = _tips[DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays % _tips.length];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          'ULTRAQUAD ERP',
          style: AppTextStyles.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.teal,
            child: Text(
              firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const AppDrawer(current: AppSection.dashboard),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => Future.wait([
            ref.refresh(contributionsProvider.future),
            ref.refresh(finesProvider.future),
            ref.refresh(pushDaysProvider.future),
            ref.read(notificationsProvider.notifier).fetch(),
          ]),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text('Welcome back, $firstName', style: AppTextStyles.heading1.copyWith(fontSize: 23)),
                  ),
                  const Text('👋', style: TextStyle(fontSize: 22)),
                ],
              ),
              const SizedBox(height: 4),
              Text("Here's what's happening with your account today.", style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(DateFormat('EEEE, MMMM d, y').format(DateTime.now()), style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              _StatsRow(stats: stats),
              const SizedBox(height: 22),
              _SectionLabel('QUICK ACTIONS'),
              const SizedBox(height: 10),
              _QuickActions(pendingFines: stats.pendingFines),
              const SizedBox(height: 22),
              _RecentActivityCard(notifications: notifications),
              const SizedBox(height: 16),
              _TipCard(tip: tip),
              const SizedBox(height: 24),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8, fontSize: 11.5),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final trend = stats.contributionTrendPercent;
    final pushPercent = ((stats.daysActiveThisMonth / stats.monthlyTarget) * 100).clamp(0, 100).round();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SoftCard(
                radius: 16,
                topAccentColor: AppColors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text("Month's contribution", style: AppTextStyles.caption, maxLines: 2)),
                        const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.teal),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('KES ${stats.thisMonthContribution.toStringAsFixed(0)}', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    if (trend != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(trend >= 0 ? Icons.trending_up : Icons.trending_down, size: 13, color: trend >= 0 ? AppColors.green : AppColors.red),
                          const SizedBox(width: 3),
                          Text(
                            '${trend >= 0 ? '+' : ''}$trend% vs last month',
                            style: AppTextStyles.caption.copyWith(color: trend >= 0 ? AppColors.green : AppColors.red, fontSize: 10.5),
                          ),
                        ],
                      )
                    else
                      Text('First month on record', style: AppTextStyles.caption.copyWith(fontSize: 10.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SoftCard(
                radius: 16,
                topAccentColor: AppColors.red,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('Pending fines', style: AppTextStyles.caption, maxLines: 2)),
                        const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.red),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('KES ${stats.pendingFines.toStringAsFixed(0)}', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    if (stats.pendingFinesCount > 0)
                      StatusBadge(label: '${stats.pendingFinesCount} pending', color: AppColors.red)
                    else
                      Text('All clear', style: AppTextStyles.caption.copyWith(color: AppColors.green, fontSize: 10.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SoftCard(
          radius: 16,
          topAccentColor: AppColors.amberDeep,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Push days', style: AppTextStyles.caption),
                        const Spacer(),
                        const Icon(Icons.code_rounded, size: 16, color: AppColors.amberDeep),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${stats.daysActiveThisMonth}/${stats.monthlyTarget}', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: pushPercent / 100,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        color: AppColors.amberDeep,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('$pushPercent% of this month\'s target', style: AppTextStyles.caption.copyWith(fontSize: 10.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.pendingFines});

  final double pendingFines;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Make Payment',
                icon: Icons.payments_outlined,
                filled: true,
                color: AppColors.amberDeep,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PaymentScreen(prefilledAmount: pendingFines > 0 ? pendingFines : null)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                label: 'View Fines',
                icon: Icons.warning_amber_rounded,
                filled: false,
                color: AppColors.red,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FinesScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Contributions',
                icon: Icons.account_balance_wallet_outlined,
                filled: false,
                color: AppColors.teal,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContributionsScreen())),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                label: 'Push Days',
                icon: Icons.code_rounded,
                filled: false,
                color: AppColors.navy,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PushDaysScreen())),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({required this.label, required this.icon, required this.filled, required this.color, required this.onTap});

  final String label;
  final IconData icon;
  final bool filled;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.filled ? widget.color : AppColors.surface;
    final fg = widget.filled ? Colors.white : widget.color;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: widget.filled ? null : Border.all(color: widget.color.withValues(alpha: 0.4)),
            boxShadow: widget.filled
                ? [BoxShadow(color: widget.color.withValues(alpha: 0.28), blurRadius: 12, offset: const Offset(0, 5))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 17, color: fg),
              const SizedBox(width: 8),
              Text(widget.label, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.notifications});

  final List<AppNotification> notifications;

  IconData _iconFor(String type) {
    switch (type) {
      case 'payment_received':
        return Icons.smartphone_outlined;
      case 'fine_created':
        return Icons.warning_amber_rounded;
      case 'daily_push_reminder':
        return Icons.code_rounded;
      default:
        return Icons.campaign_outlined;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'payment_received':
        return AppColors.green;
      case 'fine_created':
        return AppColors.red;
      case 'daily_push_reminder':
        return AppColors.navy;
      default:
        return AppColors.amberDeep;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...notifications]..sort((a, b) => (b.sentAt ?? DateTime(0)).compareTo(a.sentAt ?? DateTime(0)));
    final recent = sorted.take(5).toList();

    return SoftCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Recent activity', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 15))),
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                child: Text('See all', style: AppTextStyles.caption.copyWith(color: AppColors.teal, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Nothing yet — activity will show up here.', style: AppTextStyles.caption),
            )
          else
            ...recent.map((n) {
              final color = _colorFor(n.type);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(_iconFor(n.type), size: 16, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                          if (n.sentAt != null)
                            Text(relativeTimeLabel(n.sentAt!), style: AppTextStyles.caption.copyWith(fontSize: 10.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final _Tip tip;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: 20,
      topAccentColor: AppColors.amber,
      color: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.tips_and_updates_outlined, size: 17, color: AppColors.amberDeep),
              ),
              const SizedBox(width: 10),
              Text('Tip of the day', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          Text(tip.text, style: AppTextStyles.body.copyWith(fontSize: 13, height: 1.4)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => tip.screenBuilder())),
            child: Text(
              '${tip.actionLabel} →',
              style: AppTextStyles.body.copyWith(color: AppColors.amberDeep, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppColors.border),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('UltraQuad ERP · v1.0.0 · © ${DateTime.now().year}', style: AppTextStyles.caption.copyWith(fontSize: 10.5)),
            Text('support@ultraquad.app', style: AppTextStyles.caption.copyWith(fontSize: 10.5)),
          ],
        ),
      ],
    );
  }
}
