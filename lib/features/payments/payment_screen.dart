import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../contributions/providers/contributions_provider.dart';
import '../fines/providers/fines_provider.dart';
import 'models/payment.dart';
import 'providers/payments_provider.dart';

/// Lets the member pay fines/contributions via M-Pesa STK push
/// (POST /payments/initiate) and polls the result
/// (GET /payments/:checkoutRequestId/status).
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, this.prefilledAmount});

  final double? prefilledAmount;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSubmitting = false;
  String? _checkoutRequestId;
  String? _customerMessage;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledAmount != null && widget.prefilledAmount! > 0) {
      _amountController.text = widget.prefilledAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final initiation = await ref.read(paymentsProvider.notifier).initiate(
            amount: double.parse(_amountController.text.trim()),
            phone: _phoneController.text.trim(),
          );
      setState(() {
        _checkoutRequestId = initiation.checkoutRequestId;
        _customerMessage = initiation.customerMessage;
      });
      _startPolling(initiation.checkoutRequestId);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _startPolling(String checkoutRequestId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final status = await ref.read(paymentsProvider.notifier).checkStatus(checkoutRequestId);
      if (!status.isPending) {
        _pollTimer?.cancel();
        if (status.isSuccess) {
          ref.invalidate(finesProvider);
          ref.invalidate(contributionsProvider);
        }
      }
    });
  }

  void _reset() {
    _pollTimer?.cancel();
    ref.read(paymentsProvider.notifier).reset();
    setState(() {
      _checkoutRequestId = null;
      _customerMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(paymentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Make a Payment')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _checkoutRequestId == null
              ? _buildForm()
              : _buildStatus(statusAsync.valueOrNull, statusAsync.hasError),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Enter the amount to pay via M-Pesa.', style: AppTextStyles.body),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount (KES)'),
            validator: (value) {
              final amount = double.tryParse(value?.trim() ?? '');
              if (amount == null || amount <= 0) return 'Enter a valid amount';
              if (amount > 150000) return 'Amount is too large';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'M-Pesa phone (optional)',
              hintText: '07XXXXXXXX',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Pay with M-Pesa', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(PaymentStatus? status, bool hasError) {
    final isPending = status == null || status.isPending;
    final isSuccess = status?.isSuccess ?? false;

    return Column(
      children: [
        const SizedBox(height: 24),
        Icon(
          isSuccess
              ? Icons.check_circle_outline
              : isPending
                  ? Icons.hourglass_top_rounded
                  : Icons.error_outline,
          size: 64,
          color: isSuccess
              ? AppColors.green
              : isPending
                  ? AppColors.teal
                  : AppColors.red,
        ),
        const SizedBox(height: 16),
        Text(
          isSuccess
              ? 'Payment received'
              : isPending
                  ? 'Waiting for confirmation…'
                  : 'Payment ${status.status}',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (isPending && _customerMessage != null)
          Text(_customerMessage!, style: AppTextStyles.body, textAlign: TextAlign.center),
        if (!isPending && status.resultDesc != null)
          Text(status.resultDesc!, style: AppTextStyles.body, textAlign: TextAlign.center),
        if (isSuccess && status?.mpesaReceipt != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Receipt: ${status?.mpesaReceipt}', style: AppTextStyles.caption),
          ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Could not check payment status', style: AppTextStyles.body.copyWith(color: AppColors.red)),
          ),
        const SizedBox(height: 24),
        if (!isPending)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _reset,
              child: const Text('Make another payment'),
            ),
          ),
      ],
    );
  }
}
