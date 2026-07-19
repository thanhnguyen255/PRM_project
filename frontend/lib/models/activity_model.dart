class ActivityModel {
  final int id;
  final int learningPathId;
  final String title;
  final String? description;
  final String type; // PreClass, InClass, PostClass
  final DateTime? deadline;

  ActivityModel({required this.id, required this.learningPathId, required this.title, this.description, required this.type, this.deadline});

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
    id:             json['id'],
    learningPathId: json['learningPathId'],
    title:          json['title'],
    description:    json['description'],
    type:           json['type'],
    deadline:       json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
  );
}
