class Equipment {
  final String id;
  final String projectId;
  final String name;
  final String type;
  final double rentalRate;
  final String rentalUnit;
  final String fuelType;
  final String status;
  final DateTime? createdAt;

  Equipment({
    required this.id,
    required this.projectId,
    required this.name,
    required this.type,
    required this.rentalRate,
    required this.rentalUnit,
    required this.fuelType,
    required this.status,
    this.createdAt,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['_id'] ?? '',
      projectId: json['projectId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      rentalRate: (json['rentalRate'] ?? 0).toDouble(),
      rentalUnit: json['rentalUnit'] ?? '',
      fuelType: json['fuelType'] ?? 'None',
      status: json['status'] ?? 'Active',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'name': name,
      'type': type,
      'rentalRate': rentalRate,
      'rentalUnit': rentalUnit,
      'fuelType': fuelType,
      'status': status,
    };
  }
}
