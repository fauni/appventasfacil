class SapSeries {
  final int series;
  final String seriesName;
  final int objectCode;
  final String indicator;
  final int nextNumber;
  final int lastNum;
  final String prefix;
  final String suffix;
  final String remarks;
  final String groupCode;
  final bool locked;
  final int periodoValidFrom;
  final int periodoValidTo;

  SapSeries({
    required this.series,
    required this.seriesName,
    required this.objectCode,
    required this.indicator,
    required this.nextNumber,
    required this.lastNum,
    required this.prefix,
    required this.suffix,
    required this.remarks,
    required this.groupCode,
    required this.locked,
    required this.periodoValidFrom,
    required this.periodoValidTo,
  });

  factory SapSeries.fromJson(Map<String, dynamic> json) {
    return SapSeries(
      series: json['series'] ?? 0,
      seriesName: json['seriesName'] ?? '',
      objectCode: json['objectCode'] ?? 0,
      indicator: json['indicator'] ?? '',
      nextNumber: json['nextNumber'] ?? 0,
      lastNum: json['lastNum'] ?? 0,
      prefix: json['prefix'] ?? '',
      suffix: json['suffix'] ?? '',
      remarks: json['remarks'] ?? '',
      groupCode: json['groupCode'] ?? '',
      locked: json['locked'] ?? false,
      periodoValidFrom: json['periodoValidFrom'] ?? 0,
      periodoValidTo: json['periodoValidTo'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'series': series,
      'seriesName': seriesName,
      'objectCode': objectCode,
      'indicator': indicator,
      'nextNumber': nextNumber,
      'lastNum': lastNum,
      'prefix': prefix,
      'suffix': suffix,
      'remarks': remarks,
      'groupCode': groupCode,
      'locked': locked,
      'periodoValidFrom': periodoValidFrom,
      'periodoValidTo': periodoValidTo,
    };
  }

  // Método para mostrar información completa de la serie
  String get displayName => '$series - $seriesName';
  String get displayDetails => '$prefix${nextNumber.toString().padLeft(6, '0')}$suffix';
}