import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'providers/auth_provider.dart';

/// Registration form: posts a new account to /auth/register and shows a
/// toast on success. Laid out to fit a single screen without scrolling.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _githubController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _githubController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authProvider.notifier).signup(
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            githubUsername: _githubController.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully!'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
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
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _decoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  40,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const _Brand(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create your account', style: AppTextStyles.heading2),
                      const SizedBox(height: 2),
                      Text(
                        "Join your team's accountability ledger.",
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  _FieldLabel('Full name'),
                  TextFormField(
                    controller: _nameController,
                    decoration: _decoration('Jane Doe'),
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Full name is required' : null,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Phone number'),
                            TextFormField(
                              controller: _phoneController,
                              decoration: _decoration('+254 7XX XXX XXX'),
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              validator: (value) => (value == null || value.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('GitHub username'),
                            TextFormField(
                              controller: _githubController,
                              decoration: _decoration('janedoe'),
                              textInputAction: TextInputAction.next,
                              validator: (value) => (value == null || value.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Email'),
                      TextFormField(
                        controller: _emailController,
                        decoration: _decoration('you@team.com'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Email is required';
                          if (!value.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Password'),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _decoration(
                          '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password is required';
                          if (value.length < 8) return 'Password must be at least 8 characters';
                          return null;
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Create account', style: AppTextStyles.button),
                    ),
                  ),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.body,
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Sign in',
                            style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
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
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.bolt, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Text('UltraQuad ERP', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}
