import 'package:equatable/equatable.dart';

class SalesOrder extends Equatable {
  final int docEntry;
  final int docNum;
  final DateTime taxDate;
  final DateTime docDate;
  final String cardCode;
  final String cardName;
  final String docType;
  final int slpCode;
  final String slpName;
  final int groupNum;
  final String pymntGroup;
  final String uLbNit;
  final String uLbRazonSocial;
  final double discPrcnt;
  final double vatSum;
  final double docTotal;
  final String docCur;
  final String comments;
  final String docStatus;
  final List<SalesOrderLine> lines;

  const SalesOrder({
    required this.docEntry,
    required this.docNum,
    required this.taxDate,
    required this.docDate,
    required this.cardCode,
    required this.cardName,
    required this.docType,
    required this.slpCode,
    required this.slpName,
    required this.groupNum,
    required this.pymntGroup,
    required this.uLbNit,
    required this.uLbRazonSocial,
    required this.discPrcnt,
    required this.vatSum,
    required this.docTotal,
    required this.docCur,
    required this.comments,
    required this.docStatus,
    required this.lines,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      docEntry: json['docEntry'] ?? 0,
      docNum: json['docNum'] ?? 0,
      taxDate: DateTime.parse(json['taxDate']),
      docDate: DateTime.parse(json['docDate']),
      cardCode: json['cardCode'] ?? '',
      cardName: json['cardName'] ?? '',
      docType: json['docType'] ?? '',
      slpCode: json['slpCode'] ?? 0,
      slpName: json['slpName'] ?? '',
      groupNum: json['groupNum'] ?? 0,
      pymntGroup: json['pymntGroup'] ?? '',
      uLbNit: json['u_LB_NIT'] ?? '',
      uLbRazonSocial: json['u_LB_RazonSocial'] ?? '',
      discPrcnt: (json['discPrcnt'] as num?)?.toDouble() ?? 0.0,
      vatSum: (json['vatSum'] as num?)?.toDouble() ?? 0.0,
      docTotal: (json['docTotal'] as num?)?.toDouble() ?? 0.0,
      docCur: json['docCur'] ?? '',
      comments: json['comments'] ?? '',
      docStatus: json['docStatus'] ?? '',
      lines: (json['lines'] as List<dynamic>?)
          ?.map((line) => SalesOrderLine.fromJson(line))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docEntry': docEntry,
      'docNum': docNum,
      'taxDate': taxDate.toIso8601String(),
      'docDate': docDate.toIso8601String(),
      'cardCode': cardCode,
      'cardName': cardName,
      'docType': docType,
      'slpCode': slpCode,
      'slpName': slpName,
      'groupNum': groupNum,
      'pymntGroup': pymntGroup,
      'u_LB_NIT': uLbNit,
      'u_LB_RazonSocial': uLbRazonSocial,
      'discPrcnt': discPrcnt,
      'vatSum': vatSum,
      'docTotal': docTotal,
      'docCur': docCur,
      'comments': comments,
      'docStatus': docStatus,
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }

  String get docStatusDisplay {
    switch (docStatus) {
      case 'O':
        return 'Abierta';
      case 'C':
        return 'Cerrada';
      default:
        return docStatus;
    }
  }

  bool get isOpen => docStatus == 'O';
  bool get isClosed => docStatus == 'C';

  @override
  List<Object?> get props => [
    docEntry, docNum, taxDate, docDate, cardCode, cardName, docType,
    slpCode, slpName, groupNum, pymntGroup, uLbNit, uLbRazonSocial,
    discPrcnt, vatSum, docTotal, docCur, comments, docStatus, lines,
  ];
}

class SalesOrderLine extends Equatable {
  final int lineNum;
  final String itemCode;
  final String itemName;
  final String uDescitemfacil;
  final double quantity;
  final double priceAfVAT;
  final String currency;
  final double discPrcnt;
  final double lineTotal;
  final double gTotal;
  final String whsCode;
  final String whsName;
  final String uomCode;
  final String lineStatus;
  final String uTfeCodeUMfact;
  final String uTfeNomUMfact;

  const SalesOrderLine({
    required this.lineNum,
    required this.itemCode,
    required this.itemName,
    required this.uDescitemfacil,
    required this.quantity,
    required this.priceAfVAT,
    required this.currency,
    required this.discPrcnt,
    required this.lineTotal,
    required this.gTotal,
    required this.whsCode,
    required this.whsName,
    required this.uomCode,
    required this.lineStatus,
    required this.uTfeCodeUMfact,
    required this.uTfeNomUMfact,
  });

  factory SalesOrderLine.fromJson(Map<String, dynamic> json) {
    return SalesOrderLine(
      lineNum: json['lineNum'] ?? 0,
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      uDescitemfacil: json['u_descitemfacil'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      priceAfVAT: (json['priceAfVAT'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? '',
      discPrcnt: (json['discPrcnt'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
      gTotal: (json['gTotal'] as num?)?.toDouble() ?? 0.0,
      whsCode: json['whsCode'] ?? '',
      whsName: json['whsName'] ?? '',
      uomCode: json['uomCode'] ?? '',
      lineStatus: json['lineStatus'] ?? '',
      uTfeCodeUMfact: json['u_TFE_codUMfact'] ?? '',
      uTfeNomUMfact: json['u_TFE_nomUMfact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lineNum': lineNum,
      'itemCode': itemCode,
      'itemName': itemName,
      'u_descitemfacil': uDescitemfacil,
      'quantity': quantity,
      'priceAfVAT': priceAfVAT,
      'currency': currency,
      'discPrcnt': discPrcnt,
      'lineTotal': lineTotal,
      'gTotal': gTotal,
      'whsCode': whsCode,
      'whsName': whsName,
      'uomCode': uomCode,
      'lineStatus': lineStatus,
      'u_TFE_codUMfact': uTfeCodeUMfact,
      'u_TFE_nomUMfact': uTfeNomUMfact,
    };
  }

  String get lineStatusDisplay {
    switch (lineStatus) {
      case 'O':
        return 'Abierta';
      case 'C':
        return 'Cerrada';
      default:
        return lineStatus;
    }
  }

  String get displayName {
    if (uDescitemfacil.isNotEmpty) {
      return '$itemName ($uDescitemfacil)';
    }
    return itemName;
  }

  @override
  List<Object?> get props => [
    lineNum, itemCode, itemName, uDescitemfacil, quantity, priceAfVAT,
    currency, discPrcnt, lineTotal, gTotal, whsCode, whsName, uomCode,
    lineStatus, uTfeCodeUMfact, uTfeNomUMfact,
  ];
}