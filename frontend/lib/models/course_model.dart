class CourseModel {
  final int id;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final int instructorId;
  final String instructorName;

  CourseModel({required this.id, required this.title, this.description, this.coverImageUrl, required this.instructorId, required this.instructorName});

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
    id:             json['id'],
    title:          json['title'],
    description:    json['description'],
    coverImageUrl:  json['coverImageUrl'],
    instructorId:   json['instructorId'],
    instructorName: json['instructorName'] ?? '',
  );
}
