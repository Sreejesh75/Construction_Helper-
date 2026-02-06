class ConstructionProgressModel {
  final String? id;
  final String projectId;
  final String section;
  final int progress;
  final String status;
  final String startDate;
  final String endDate;
  final String remarks;

  ConstructionProgressModel({
    this.id,
    required this.projectId,
    required this.section,
    required this.progress,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.remarks,
  });

  factory ConstructionProgressModel.fromJson(Map<String, dynamic> json) {
    return ConstructionProgressModel(
      id: json['_id'],
      projectId: json['projectId'] ?? '',
      section: json['section'] ?? '',
      progress: (json['progress'] ?? 0).toInt(),
      status: json['status'] ?? 'Start',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'projectId': projectId,
      'section': section,
      'progress': progress,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
      'remarks': remarks,
    };
  }
}
