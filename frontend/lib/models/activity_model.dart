class ActivityModel {
  final int id;
  final int learningPathId;
  final String title;
  final String? description;
  final String type; // PreClass, InClass, PostClass
  final String? submissionStatus;

  ActivityModel({
    required this.id, 
    required this.learningPathId, 
    required this.title, 
    this.description, 
    required this.type, 
    this.deadline,
    this.submissionStatus,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
    id:               json['id'] ?? 0,
    learningPathId:   json['learningPathId'] ?? 0,
    title:            json['title'] ?? '',
    description:      json['description'],
    type:             json['type'] ?? '',
    deadline:         json['deadline'] != null ? DateTime.tryParse(json['deadline']) : null,
    submissionStatus: json['submissionStatus'] ?? (json['submission'] != null ? json['submission']['status'] : null),
  );
}
