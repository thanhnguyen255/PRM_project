class ClassModel {
  final int id;
  final int courseId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  ClassModel({required this.id, required this.courseId, required this.name, required this.startDate, required this.endDate});

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
    id:        json['id'],
    courseId:  json['courseId'],
    name:      json['name'],
    startDate: DateTime.parse(json['startDate']),
    endDate:   DateTime.parse(json['endDate']),
  );
}
