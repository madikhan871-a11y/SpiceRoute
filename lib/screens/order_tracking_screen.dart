import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({
    super.key,
    required this.appState,
    required this.order,
  });

  final AppState appState;
  final Order order;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
    final msg = widget.appState.thankYouMessage;
    if (msg != null && widget.order.status == OrderStatus.delivered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.appState.thankYouMessage == null) return;
        _showThankYou(msg);
      });
    }
  }

  void _showThankYou(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 40,
          ),
        ),
        title: const Text('Thank You!'),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              widget.appState.dismissThankYou();
              Navigator.of(ctx).pop();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final delivered = order.status == OrderStatus.delivered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: delivered
                    ? [AppColors.success, const Color(0xFF166534)]
                    : [AppColors.secondary, const Color(0xFF6A040F)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivered ? 'Delivered Successfully' : 'Order Confirmed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Order ID: ${order.id}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Paid via ${order.paymentMethod.label}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: Rs ${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Delivery Status',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _StatusStep(
            title: 'Order Placed',
            subtitle: 'We received your order',
            active: true,
          ),
          _StatusStep(
            title: 'Preparing',
            subtitle: 'Kitchen is preparing your food',
            active: order.status.index >= OrderStatus.preparing.index,
          ),
          _StatusStep(
            title: 'On the Way',
            subtitle: 'Rider is heading to your address',
            active: order.status.index >= OrderStatus.onTheWay.index,
          ),
          _StatusStep(
            title: 'Delivered',
            subtitle: 'Enjoy your meal!',
            active: delivered,
            isLast: true,
          ),
          const SizedBox(height: 28),
          const Text(
            'Items',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}× ${item.product.name}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    'Rs ${item.total.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(appState: widget.appState),
                  ),
                  (_) => false,
                );
              },
              child: const Text('Back to Menu'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  const _StatusStep({
    required this.title,
    required this.subtitle,
    required this.active,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                active ? Icons.check_rounded : Icons.circle,
                size: active ? 16 : 8,
                color: active ? Colors.white : AppColors.muted,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: active ? AppColors.primary : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24, top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: active ? AppColors.text : AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
