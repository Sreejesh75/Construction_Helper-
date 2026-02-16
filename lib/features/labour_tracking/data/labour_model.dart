class Labour {
  final String? id;
  final String projectId;
  final String mode;
  final DateTime date;
  final ContractDetails? contractDetails;
  final DailyLabourDetails? dailyLabourDetails;

  Labour({
    this.id,
    required this.projectId,
    required this.mode,
    required this.date,
    this.contractDetails,
    this.dailyLabourDetails,
  });

  factory Labour.fromJson(Map<String, dynamic> json) {
    return Labour(
      id: json['_id'],
      projectId: json['projectId'],
      mode: json['mode'],
      date: DateTime.parse(json['date']),
      contractDetails: json['contractDetails'] != null
          ? ContractDetails.fromJson(json['contractDetails'])
          : null,
      dailyLabourDetails: json['dailyLabourDetails'] != null
          ? DailyLabourDetails.fromJson(json['dailyLabourDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'mode': mode,
      'date': date.toIso8601String(),
      if (contractDetails != null) 'contractDetails': contractDetails!.toJson(),
      if (dailyLabourDetails != null)
        'dailyLabourDetails': dailyLabourDetails!.toJson(),
    };
  }
}

class ContractDetails {
  final String contractorName;
  final double estimatedAmount;
  final double paidAmount;

  ContractDetails({
    required this.contractorName,
    required this.estimatedAmount,
    required this.paidAmount,
  });

  factory ContractDetails.fromJson(Map<String, dynamic> json) {
    return ContractDetails(
      contractorName: json['contractorName'],
      estimatedAmount: (json['estimatedAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contractorName': contractorName,
      'estimatedAmount': estimatedAmount,
      'paidAmount': paidAmount,
    };
  }
}

class DailyLabourDetails {
  final List<Labourer> labourers;
  final double totalAmount;

  DailyLabourDetails({required this.labourers, required this.totalAmount});

  factory DailyLabourDetails.fromJson(Map<String, dynamic> json) {
    return DailyLabourDetails(
      labourers: (json['labourers'] as List)
          .map((e) => Labourer.fromJson(e))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'labourers': labourers.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
    };
  }
}

class Labourer {
  final String name;
  final double wage;

  Labourer({required this.name, required this.wage});

  factory Labourer.fromJson(Map<String, dynamic> json) {
    return Labourer(name: json['name'], wage: (json['wage'] as num).toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'wage': wage};
  }
}
