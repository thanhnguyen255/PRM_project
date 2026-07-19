class ActivityModel {
  final int id;
  final int learningPathId;
  final String title;
  final String? description;
  final String type; // PreClass, InClass, PostClass
  final DateTime? deadline;
  final String? submissionStatus;
  final int? reviewSessionId;
  final String? reviewSessionTitle;
  final bool? isReviewSessionOpen;

  ActivityModel({
    required this.id, 
    required this.learningPathId, 
    required this.title, 
    this.description, 
    required this.type, 
    this.deadline,
    this.submissionStatus,
    this.reviewSessionId,
    this.reviewSessionTitle,
    this.isReviewSessionOpen,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
    id:               json['id'] ?? 0,
    learningPathId:   json['learningPathId'] ?? 0,
    title:            json['title'] ?? '',
    description:      json['description'],
    type:             json['type'] ?? '',
    deadline:         json['deadline'] != null ? DateTime.tryParse(json['deadline']) : null,
    submissionStatus: json['submissionStatus'] ?? (json['submission'] != null ? json['submission']['status'] : null),
    reviewSessionId:  json['reviewSessionId'] as int?,
    reviewSessionTitle: json['reviewSessionTitle'] as String?,
    isReviewSessionOpen: json['isReviewSessionOpen'] as bool?,
  );
}
