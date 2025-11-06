class Order {
  final String id;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final DateTime orderDate;
  final String status;
  final String? deliveryAddress;
  final String? paymentMethod;
  final DateTime? estimatedDelivery;
  final String? trackingId;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    this.deliveryAddress,
    this.paymentMethod,
    this.estimatedDelivery,
    this.trackingId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items,
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'trackingId': trackingId,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
      deliveryAddress: json['deliveryAddress'],
      paymentMethod: json['paymentMethod'],
      estimatedDelivery: json['estimatedDelivery'] != null 
          ? DateTime.parse(json['estimatedDelivery']) 
          : null,
      trackingId: json['trackingId'],
    );
  }
}
