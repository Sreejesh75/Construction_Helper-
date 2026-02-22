class EquipmentLog {
  final String id;
  final String equipmentId;
  final DateTime date;
  final double hoursUsed;
  final double fuelConsumed;
  final double fuelCost;
  final double rentalCost;
  final double totalCost;
  final String remarks;

  EquipmentLog({
    required this.id,
    required this.equipmentId,
    required this.date,
    required this.hoursUsed,
    required this.fuelConsumed,
    required this.fuelCost,
    required this.rentalCost,
    required this.totalCost,
    required this.remarks,
  });

  factory EquipmentLog.fromJson(Map<String, dynamic> json) {
    return EquipmentLog(
      id: json['_id'] ?? '',
      equipmentId: json['equipmentId'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      hoursUsed: (json['hoursUsed'] ?? 0).toDouble(),
      fuelConsumed: (json['fuelConsumed'] ?? 0).toDouble(),
      fuelCost: (json['fuelCost'] ?? 0).toDouble(),
      rentalCost: (json['rentalCost'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      remarks: json['remarks'] ?? '',
    );
  }
}
