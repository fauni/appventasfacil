class SalesPerson {
  final int slpCode;
  final String slpName;
  final String memo;
  final String active;
  final bool isActive;
  final String displayName;

  SalesPerson({
    required this.slpCode,
    required this.slpName,
    required this.memo,
    required this.active,
    required this.isActive,
    required this.displayName,
  });

  factory SalesPerson.fromJson(Map<String, dynamic> json) {
    return SalesPerson(
      slpCode: json['slpCode'],
      slpName: json['slpName'] ?? '',
      memo: json['memo'] ?? '',
      active: json['active'] ?? 'N',
      isActive: json['isActive'] ?? false,
      displayName: json['displayName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slpCode': slpCode,
      'slpName': slpName,
      'memo': memo,
      'active': active,
      'isActive': isActive,
      'displayName': displayName,
    };
  }
}