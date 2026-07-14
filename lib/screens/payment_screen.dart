import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'order_tracking_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.appState,
    required this.deliveryFee,
  });

  final AppState appState;
  final double deliveryFee;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.cashOnDelivery;
  final _walletController = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _walletController.dispose();
    super.dispose();
  }

  Future<void> _confirmPayment() async {
    if (_method != PaymentMethod.cashOnDelivery) {
      final number = _walletController.text.trim();
      if (number.isEmpty || number.length < 11) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Enter a valid ${_method.label} mobile number (11 digits)',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final order = widget.appState.placeOrder(
      _method,
      deliveryFee: widget.deliveryFee,
    );
    setState(() => _processing = false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => OrderTrackingScreen(
          appState: widget.appState,
          order: order,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.appState.cartTotal;
    final total = subtotal + widget.deliveryFee;
    final user = widget.appState.user!;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Method')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deliver to',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.address,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select payment method',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          _PaymentOption(
            method: PaymentMethod.jazzCash,
            selected: _method == PaymentMethod.jazzCash,
            color: AppColors.jazzCash,
            icon: Icons.account_balance_wallet_rounded,
            onTap: () => setState(() => _method = PaymentMethod.jazzCash),
          ),
          const SizedBox(height: 10),
          _PaymentOption(
            method: PaymentMethod.easyPaisa,
            selected: _method == PaymentMethod.easyPaisa,
            color: AppColors.easyPaisa,
            icon: Icons.phone_android_rounded,
            onTap: () => setState(() => _method = PaymentMethod.easyPaisa),
          ),
          const SizedBox(height: 10),
          _PaymentOption(
            method: PaymentMethod.cashOnDelivery,
            selected: _method == PaymentMethod.cashOnDelivery,
            color: AppColors.cod,
            icon: Icons.payments_rounded,
            onTap: () => setState(() => _method = PaymentMethod.cashOnDelivery),
          ),
          if (_method != PaymentMethod.cashOnDelivery) ...[
            const SizedBox(height: 20),
            TextFormField(
              controller: _walletController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: '${_method.label} Mobile Number',
                hintText: '03XXXXXXXXX',
                prefixIcon: const Icon(Icons.smartphone_rounded),
              ),
            ),
          ],
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Column(
              children: [
                _PayRow(label: 'Subtotal', value: subtotal),
                const SizedBox(height: 8),
                _PayRow(label: 'Delivery', value: widget.deliveryFee),
                const Divider(height: 20),
                _PayRow(label: 'Amount Payable', value: total, bold: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _processing ? null : _confirmPayment,
              child: _processing
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _method == PaymentMethod.cashOnDelivery
                          ? 'Place Order (Cash on Delivery)'
                          : 'Pay with ${_method.label}',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.method,
    required this.selected,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? color : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  const _PayRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            fontSize: bold ? 15 : 13,
            color: bold ? AppColors.text : AppColors.muted,
          ),
        ),
        Text(
          'Rs ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            fontSize: bold ? 17 : 13,
            color: bold ? AppColors.primary : AppColors.text,
          ),
        ),
      ],
    );
  }
}
