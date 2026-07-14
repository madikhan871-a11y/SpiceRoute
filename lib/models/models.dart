import 'package:flutter/material.dart';

class UserProfile {
  final String name;
  final String email;
  final String address;

  const UserProfile({
    required this.name,
    required this.email,
    required this.address,
  });
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final IconData icon;
  final Color color;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.icon,
    required this.color,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

enum PaymentMethod {
  jazzCash(
    'JazzCash',
    'Pay securely via JazzCash wallet',
  ),
  easyPaisa(
    'EasyPaisa',
    'Pay securely via EasyPaisa wallet',
  ),
  cashOnDelivery(
    'Cash on Delivery',
    'Pay with cash when order arrives',
  );

  const PaymentMethod(this.label, this.subtitle);

  final String label;
  final String subtitle;
}

enum OrderStatus { placed, preparing, onTheWay, delivered }

class Order {
  final String id;
  final List<CartItem> items;
  final PaymentMethod paymentMethod;
  final double total;
  final DateTime placedAt;
  OrderStatus status;
  bool thankYouSent;

  Order({
    required this.id,
    required this.items,
    required this.paymentMethod,
    required this.total,
    required this.placedAt,
    this.status = OrderStatus.placed,
    this.thankYouSent = false,
  });
}

class Complaint {
  final String id;
  final String subject;
  final String message;
  final DateTime createdAt;
  String status;

  Complaint({
    required this.id,
    required this.subject,
    required this.message,
    required this.createdAt,
    this.status = 'Submitted',
  });
}
