import 'package:equatable/equatable.dart';

class PaymentMethod extends Equatable {
  final String code;
  final String name;

  const PaymentMethod({
    required this.code,
    required this.name,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }

  String get displayText => '$code - $name';

  @override
  List<Object?> get props => [code, name];
}

class DeliveryTime extends Equatable {
  final String code;
  final String name;

  const DeliveryTime({
    required this.code,
    required this.name,
  });

  factory DeliveryTime.fromJson(Map<String, dynamic> json) {
    return DeliveryTime(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }

  String get displayText => '$code - $name';

  @override
  List<Object?> get props => [code, name];
}

class OfferValidity extends Equatable {
  final String code;
  final String name;

  const OfferValidity({
    required this.code,
    required this.name,
  });

  factory OfferValidity.fromJson(Map<String, dynamic> json) {
    return OfferValidity(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }

  String get displayText => '$code - $name';

  @override
  List<Object?> get props => [code, name];
}

class TermsConditions extends Equatable {
  final List<PaymentMethod> paymentMethods;
  final List<DeliveryTime> deliveryTimes;
  final List<OfferValidity> offerValidities;

  const TermsConditions({
    required this.paymentMethods,
    required this.deliveryTimes,
    required this.offerValidities,
  });

  factory TermsConditions.fromJson(Map<String, dynamic> json) {
    return TermsConditions(
      paymentMethods: (json['paymentMethods'] as List<dynamic>?)
          ?.map((item) => PaymentMethod.fromJson(item))
          .toList() ?? [],
      deliveryTimes: (json['deliveryTimes'] as List<dynamic>?)
          ?.map((item) => DeliveryTime.fromJson(item))
          .toList() ?? [],
      offerValidities: (json['offerValidities'] as List<dynamic>?)
          ?.map((item) => OfferValidity.fromJson(item))
          .toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [paymentMethods, deliveryTimes, offerValidities];
}
