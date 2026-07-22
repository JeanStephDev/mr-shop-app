class OrderItem {
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  OrderItem({required this.productName, required this.unitPrice, required this.quantity, required this.subtotal});

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productName: json['product_name'],
        unitPrice: double.parse(json['unit_price'].toString()),
        quantity: json['quantity'],
        subtotal: double.parse(json['subtotal'].toString()),
      );
}

class OrderModel {
  final int id;
  final String orderNumber;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final List<OrderItem> items;
  final String? courierName;
  final String? courierPhone;
  final bool hasReview;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.items = const [],
    this.courierName,
    this.courierPhone,
    this.hasReview = false,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'],
        orderNumber: json['order_number'],
        subtotal: double.parse(json['subtotal'].toString()),
        deliveryFee: double.parse(json['delivery_fee'].toString()),
        discount: double.parse((json['discount'] ?? 0).toString()),
        total: double.parse(json['total'].toString()),
        status: json['status'],
        paymentStatus: json['payment_status'],
        paymentMethod: json['payment_method'],
        items: (json['items'] as List? ?? []).map((i) => OrderItem.fromJson(i)).toList(),
        courierName: json['courier']?['name'],
        courierPhone: json['courier']?['phone'],
        hasReview: json['review'] != null,
      );

  // Reprend l'ordre des statuts définis côté API (Order::STATUS_FLOW)
  static const statusFlow = ['pending', 'accepted', 'preparing', 'courier_assigned', 'picked_up', 'on_the_way', 'delivered'];

  int get currentStepIndex => statusFlow.indexOf(status);
}
