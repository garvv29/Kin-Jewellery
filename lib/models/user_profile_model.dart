class UserProfile {
  String uid;
  String name;
  String email;
  String? phone;
  String? gender;
  String? profileImageUrl;
  DateTime? dateOfBirth;
  List<DeliveryAddress> addresses;
  List<PaymentMethod> paymentMethods;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.gender,
    this.profileImageUrl,
    this.dateOfBirth,
    this.addresses = const [],
    this.paymentMethods = const [],
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phone': phone,
    'gender': gender,
    'profileImageUrl': profileImageUrl,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'addresses': addresses.map((a) => a.toJson()).toList(),
    'paymentMethods': paymentMethods.map((p) => p.toJson()).toList(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    uid: json['uid'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'],
    gender: json['gender'],
    profileImageUrl: json['profileImageUrl'],
    dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
    addresses: (json['addresses'] as List?)?.map((a) => DeliveryAddress.fromJson(a)).toList() ?? [],
    paymentMethods: (json['paymentMethods'] as List?)?.map((p) => PaymentMethod.fromJson(p)).toList() ?? [],
  );
}

class DeliveryAddress {
  String id;
  String label;
  String street;
  String city;
  String state;
  String zipCode;
  String phone;
  bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phone,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'street': street,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    'phone': phone,
    'isDefault': isDefault,
  };

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) => DeliveryAddress(
    id: json['id'] ?? '',
    label: json['label'] ?? '',
    street: json['street'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    zipCode: json['zipCode'] ?? '',
    phone: json['phone'] ?? '',
    isDefault: json['isDefault'] ?? false,
  );
}

class PaymentMethod {
  String id;
  String label;
  String cardNumber;
  String cardHolder;
  String expiry;
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.label,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiry,
    this.isDefault = false,
  });

  String get maskedCardNumber =>
      '•••• •••• •••• ${cardNumber.substring(cardNumber.length - 4)}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'cardNumber': cardNumber,
    'cardHolder': cardHolder,
    'expiry': expiry,
    'isDefault': isDefault,
  };

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    id: json['id'] ?? '',
    label: json['label'] ?? '',
    cardNumber: json['cardNumber'] ?? '',
    cardHolder: json['cardHolder'] ?? '',
    expiry: json['expiry'] ?? '',
    isDefault: json['isDefault'] ?? false,
  );
}
