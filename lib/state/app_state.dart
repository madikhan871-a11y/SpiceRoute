import 'package:flutter/material.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  UserProfile? user;
  final List<CartItem> cart = [];
  final List<Order> orders = [];
  final List<Complaint> complaints = [];
  String? thankYouMessage;

  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);

  double get cartTotal => cart.fold(0, (sum, item) => sum + item.total);

  void login(UserProfile profile) {
    user = profile;
    notifyListeners();
  }

  void logout() {
    user = null;
    cart.clear();
    thankYouMessage = null;
    notifyListeners();
  }

  void addToCart(Product product) {
    final existing = cart.where((c) => c.product.id == product.id);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      cart.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    final index = cart.indexWhere((c) => c.product.id == product.id);
    if (index == -1) return;
    if (cart[index].quantity > 1) {
      cart[index].quantity--;
    } else {
      cart.removeAt(index);
    }
    notifyListeners();
  }

  void clearCartItem(Product product) {
    cart.removeWhere((c) => c.product.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  int quantityOf(Product product) {
    final match = cart.where((c) => c.product.id == product.id);
    return match.isEmpty ? 0 : match.first.quantity;
  }

  Order placeOrder(PaymentMethod method, {double deliveryFee = 80}) {
    final order = Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: cart.map((c) => CartItem(product: c.product, quantity: c.quantity)).toList(),
      paymentMethod: method,
      total: cartTotal + deliveryFee,
      placedAt: DateTime.now(),
    );
    orders.insert(0, order);
    cart.clear();
    notifyListeners();
    _simulateDelivery(order);
    return order;
  }

  void _simulateDelivery(Order order) {
    Future.delayed(const Duration(seconds: 3), () {
      order.status = OrderStatus.preparing;
      notifyListeners();
    });
    Future.delayed(const Duration(seconds: 6), () {
      order.status = OrderStatus.onTheWay;
      notifyListeners();
    });
    Future.delayed(const Duration(seconds: 10), () {
      order.status = OrderStatus.delivered;
      order.thankYouSent = true;
      thankYouMessage =
          'Thank you, ${user?.name ?? 'valued customer'}! '
          'Your order ${order.id} has been delivered successfully. '
          'We hope you enjoy your meal. Come order with us again soon!';
      notifyListeners();
    });
  }

  void dismissThankYou() {
    thankYouMessage = null;
    notifyListeners();
  }

  void submitComplaint(String subject, String message) {
    complaints.insert(
      0,
      Complaint(
        id: 'CMP${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        subject: subject,
        message: message,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
