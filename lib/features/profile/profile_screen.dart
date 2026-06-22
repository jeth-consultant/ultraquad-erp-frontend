import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_exception.dart';
import '../../core/navigation/app_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_drawer.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/welcome_screen.dart';
import 'models/profile.dart';
import 'providers/profile_provider.dart';

/// Shows and edits the signed-in member's profile (GET/PATCH /profile).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _githubController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  void _populateControllers(Profile profile) {
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _githubController.text = profile.githubUsername ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(profileProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            githubUsername: _githubController.text.trim(),
          );

      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Profile', style: AppTextStyles.heading2),
        actions: [
          if (profileAsync.hasValue)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined, color: AppColors.textPrimary),
              onPressed: () {
                setState(() {
                  if (_isEditing) {
                    _populateControllers(profileAsync.value!);
                  }
                  _isEditing = !_isEditing;
                });
              },
            ),
        ],
      ),
      drawer: const AppDrawer(current: AppSection.profile),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (!_isEditing &&
                _nameController.text.isEmpty &&
                _emailController.text.isEmpty &&
                _githubController.text.isEmpty) {
              _populateControllers(profile);
            }
            return RefreshIndicator(
              onRefresh: () => ref.read(profileProvider.notifier).fetchProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileHeader(profile: profile),
                      const SizedBox(height: 16),
                      _FieldCard(
                        label: 'Full name',
                        controller: _nameController,
                        editable: _isEditing,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Full name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      _FieldCard(
                        label: 'Phone',
                        value: profile.phone,
                        editable: false,
                      ),
                      const SizedBox(height: 12),
                      _FieldCard(
                        label: 'Email',
                        controller: _emailController,
                        editable: _isEditing,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Email is required';
                          if (!value.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _FieldCard(
                        label: 'GitHub username',
                        controller: _githubController,
                        editable: _isEditing,
                      ),
                      const SizedBox(height: 12),
                      _FieldCard(
                        label: 'Member code',
                        value: profile.memberCode,
                        editable: false,
                      ),
                      if (profile.createdAt != null) ...[
                        const SizedBox(height: 12),
                        _FieldCard(
                          label: 'Member since',
                          value: DateFormat.yMMMMd().format(profile.createdAt!),
                          editable: false,
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (_isEditing)
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _isSaving ? null : _save,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Save changes', style: AppTextStyles.button),
                          ),
                        )
                      else
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red,
                              side: const BorderSide(color: AppColors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _logout,
                            child: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error is ApiException ? error.message : 'Failed to load profile',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => ref.read(profileProvider.notifier).fetchProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final Profile profile;

  String get _initials {
    final parts = profile.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.navy,
            child: Text(
              _initials,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(profile.name, style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(profile.email, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  profile.isAdmin ? Icons.shield_outlined : Icons.person_outline,
                  size: 14,
                  color: AppColors.navy,
                ),
                const SizedBox(width: 6),
                Text(
                  profile.role.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.label,
    this.controller,
    this.value,
    required this.editable,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController? controller;
  final String? value;
  final bool editable;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.6),
          ),
          const SizedBox(height: 4),
          if (editable && controller != null)
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
            )
          else
            Text(
              value ?? controller?.text ?? '—',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}
