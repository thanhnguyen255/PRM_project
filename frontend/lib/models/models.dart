// ─── UserModel ──────────────────────────────────────────────────────────────
class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final String? avatarUrl;
  final DateTime? createdAt;
  final UserStats? stats;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.createdAt,
    this.stats,
  });

  bool get isInstructor => role == 'Instructor';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:        json['id'] as int,
    email:     json['email'] as String,
    fullName:  json['fullName'] as String,
    role:      json['role'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    stats:     json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
  );
}

class UserStats {
  final int enrolledCourses;
  final int completedActivities;

  const UserStats({required this.enrolledCourses, required this.completedActivities});

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    enrolledCourses:      json['enrolledCourses'] as int? ?? 0,
    completedActivities:  json['completedActivities'] as int? ?? 0,
  );
}

// ─── AuthResponse ────────────────────────────────────────────────────────────
class AuthResponse {
  final String token;
  final int userId;
  final String fullName;
  final String role;
  final String? avatarUrl;

  const AuthResponse({
    required this.token,
    required this.userId,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token:    json['token'] as String,
    userId:   json['userId'] as int,
    fullName: json['fullName'] as String,
    role:     json['role'] as String,
    avatarUrl: json['avatarUrl'] as String?,
  );
}

// ─── CourseModel ─────────────────────────────────────────────────────────────
class CourseModel {
  final int id;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final int instructorId;
  final String instructorName;
  final double progressPercent;
  final int? activeClassId;
  final String? activeClassName;
  final int classCount;
  final DateTime? createdAt;

  const CourseModel({
    required this.id,
    required this.title,
    this.description,
    this.coverImageUrl,
    required this.instructorId,
    required this.instructorName,
    this.progressPercent = 0.0,
    this.activeClassId,
    this.activeClassName,
    this.classCount = 0,
    this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
    id:              json['id'] as int,
    title:           json['title'] as String,
    description:     json['description'] as String?,
    coverImageUrl:   json['coverImageUrl'] as String?,
    instructorId:    json['instructorId'] as int? ?? 0,
    instructorName:  json['instructorName'] as String? ?? '',
    progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
    activeClassId:   json['activeClassId'] as int?,
    activeClassName: json['activeClassName'] as String?,
    classCount:      json['classCount'] as int? ?? 0,
    createdAt:       json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );
}

// ─── ClassModel ──────────────────────────────────────────────────────────────
class ClassModel {
  final int id;
  final int courseId;
  final String? courseTitle;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final int memberCount;
  final int weekCount;
  final double progressPercent;

  const ClassModel({
    required this.id,
    required this.courseId,
    this.courseTitle,
    required this.name,
    this.startDate,
    this.endDate,
    this.memberCount = 0,
    this.weekCount = 0,
    this.progressPercent = 0.0,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
    id:              json['id'] as int,
    courseId:        json['courseId'] as int? ?? 0,
    courseTitle:     json['courseTitle'] as String?,
    name:            json['name'] as String,
    startDate:       json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
    endDate:         json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    memberCount:     json['memberCount'] as int? ?? 0,
    weekCount:       json['weekCount'] as int? ?? 0,
    progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
  );
}

// ─── ClassMemberModel ─────────────────────────────────────────────────────────
class ClassMemberModel {
  final int userId;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final DateTime? joinedAt;

  const ClassMemberModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.joinedAt,
  });

  factory ClassMemberModel.fromJson(Map<String, dynamic> json) => ClassMemberModel(
    userId:    json['userId'] as int,
    fullName:  json['fullName'] as String,
    email:     json['email'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    joinedAt:  json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null,
  );
}

// ─── LearningPathModel ────────────────────────────────────────────────────────
class LearningPathModel {
  final int id;
  final int classId;
  final String title;
  final int weekNumber;
  final int totalActivities;
  final int completedActivities;
  final String state; // "completed" | "inProgress" | "locked"

  const LearningPathModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.weekNumber,
    this.totalActivities = 0,
    this.completedActivities = 0,
    this.state = 'locked',
  });

  double get progress => totalActivities == 0 ? 0 : completedActivities / totalActivities;

  factory LearningPathModel.fromJson(Map<String, dynamic> json) => LearningPathModel(
    id:                  json['id'] as int,
    classId:             json['classId'] as int? ?? 0,
    title:               json['title'] as String,
    weekNumber:          json['weekNumber'] as int? ?? 0,
    totalActivities:     json['totalActivities'] as int? ?? 0,
    completedActivities: json['completedActivities'] as int? ?? 0,
    state:               json['state'] as String? ?? 'locked',
  );
}

// ─── ActivityModel ────────────────────────────────────────────────────────────
class ActivityModel {
  final int id;
  final int learningPathId;
  final String title;
  final String type; // "PreClass" | "InClass" | "PostClass"
  final String? description;
  final DateTime? deadline;
  final int? submissionId;
  final String? submissionStatus; // "Pending" | "Approved" | "Rejected" | null
  final DateTime? submittedAt;

  const ActivityModel({
    required this.id,
    required this.learningPathId,
    required this.title,
    required this.type,
    this.description,
    this.deadline,
    this.submissionId,
    this.submissionStatus,
    this.submittedAt,
  });

  bool get isOverdue => deadline != null && deadline!.isBefore(DateTime.now()) && submissionStatus == null;
  bool get isUrgent  => deadline != null && deadline!.difference(DateTime.now()).inHours <= 24 && submissionStatus == null;

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
    id:               json['id'] as int,
    learningPathId:   json['learningPathId'] as int? ?? 0,
    title:            json['title'] as String,
    type:             json['type'] as String,
    description:      json['description'] as String?,
    deadline:         json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
    submissionId:     json['submissionId'] as int?,
    submissionStatus: json['submissionStatus'] as String?,
    submittedAt:      json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
  );
}

// ─── EvidenceModel ────────────────────────────────────────────────────────────
class EvidenceModel {
  final int id;
  final int activityId;
  final String activityTitle;
  final String activityType;
  final int learnerId;
  final String learnerName;
  final String? learnerAvatar;
  final String? fileUrl;
  final String? note;
  final String status; // "Pending" | "Approved" | "Rejected"
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final int commentCount;

  const EvidenceModel({
    required this.id,
    required this.activityId,
    required this.activityTitle,
    required this.activityType,
    required this.learnerId,
    required this.learnerName,
    this.learnerAvatar,
    this.fileUrl,
    this.note,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.commentCount = 0,
  });

  factory EvidenceModel.fromJson(Map<String, dynamic> json) => EvidenceModel(
    id:            json['id'] as int,
    activityId:    json['activityId'] as int? ?? 0,
    activityTitle: json['activityTitle'] as String? ?? '',
    activityType:  json['activityType'] as String? ?? 'PreClass',
    learnerId:     json['learnerId'] as int? ?? 0,
    learnerName:   json['learnerName'] as String? ?? '',
    learnerAvatar: json['learnerAvatar'] as String?,
    fileUrl:       json['fileUrl'] as String?,
    note:          json['note'] as String?,
    status:        json['status'] as String? ?? 'Pending',
    submittedAt:   DateTime.parse(json['submittedAt'] as String),
    reviewedAt:    json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
    commentCount:  json['commentCount'] as int? ?? 0,
  );
}

// ─── EvidenceCommentModel ─────────────────────────────────────────────────────
class EvidenceCommentModel {
  final int id;
  final int authorId;
  final String authorName;
  final String? authorAvatar;
  final bool isInstructor;
  final String content;
  final DateTime createdAt;

  const EvidenceCommentModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.isInstructor,
    required this.content,
    required this.createdAt,
  });

  factory EvidenceCommentModel.fromJson(Map<String, dynamic> json) => EvidenceCommentModel(
    id:           json['id'] as int,
    authorId:     json['authorId'] as int? ?? 0,
    authorName:   json['authorName'] as String? ?? '',
    authorAvatar: json['authorAvatar'] as String?,
    isInstructor: json['isInstructor'] as bool? ?? false,
    content:      json['content'] as String,
    createdAt:    DateTime.parse(json['createdAt'] as String),
  );
}

// ─── NotificationModel ────────────────────────────────────────────────────────
class NotificationModel {
  final int id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id:        json['id'] as int,
    title:     json['title'] as String,
    body:      json['body'] as String,
    isRead:    json['isRead'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

// ─── ProjectModel ─────────────────────────────────────────────────────────────
class ProjectModel {
  final int id;
  final int classId;
  final String title;
  final String? description;
  final int milestoneCount;
  final int completedMilestones;
  final String? nextMilestoneTitle;
  final DateTime? nextMilestoneDueDate;

  const ProjectModel({
    required this.id,
    required this.classId,
    required this.title,
    this.description,
    this.milestoneCount = 0,
    this.completedMilestones = 0,
    this.nextMilestoneTitle,
    this.nextMilestoneDueDate,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id:                   json['id'] as int,
    classId:              json['classId'] as int? ?? 0,
    title:                json['title'] as String,
    description:          json['description'] as String?,
    milestoneCount:       json['milestoneCount'] as int? ?? 0,
    completedMilestones:  json['completedMilestones'] as int? ?? 0,
    nextMilestoneTitle:   json['nextMilestoneTitle'] as String?,
    nextMilestoneDueDate: json['nextMilestoneDueDate'] != null
        ? DateTime.parse(json['nextMilestoneDueDate'])
        : null,
  );
}

// ─── MilestoneModel ───────────────────────────────────────────────────────────
class MilestoneModel {
  final int id;
  final int projectId;
  final String? projectTitle;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int stepNumber;
  final bool isSubmitted;
  final DateTime? submittedAt;

  const MilestoneModel({
    required this.id,
    required this.projectId,
    this.projectTitle,
    required this.title,
    this.description,
    this.dueDate,
    this.stepNumber = 1,
    this.isSubmitted = false,
    this.submittedAt,
  });

  factory MilestoneModel.fromJson(Map<String, dynamic> json) => MilestoneModel(
    id:           json['id'] as int,
    projectId:    json['projectId'] as int? ?? 0,
    projectTitle: json['projectTitle'] as String?,
    title:        json['title'] as String,
    description:  json['description'] as String?,
    dueDate:      json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    stepNumber:   json['stepNumber'] as int? ?? 1,
    isSubmitted:  json['isSubmitted'] as bool? ?? false,
    submittedAt:  json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
  );
}

// ─── ReviewSessionModel ───────────────────────────────────────────────────────
class ReviewSessionModel {
  final int id;
  final int classId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final bool isOpen;
  final int myAssignmentCount;
  final int myCompletedCount;

  const ReviewSessionModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.isOpen = false,
    this.myAssignmentCount = 0,
    this.myCompletedCount = 0,
  });

  factory ReviewSessionModel.fromJson(Map<String, dynamic> json) => ReviewSessionModel(
    id:                 json['id'] as int,
    classId:            json['classId'] as int? ?? 0,
    title:              json['title'] as String,
    startDate:          DateTime.parse(json['startDate'] as String),
    endDate:            DateTime.parse(json['endDate'] as String),
    isOpen:             json['isOpen'] as bool? ?? false,
    myAssignmentCount:  json['myAssignmentCount'] as int? ?? 0,
    myCompletedCount:   json['myCompletedCount'] as int? ?? 0,
  );
}

// ─── FeedbackModel ────────────────────────────────────────────────────────────
class FeedbackModel {
  final int id;
  final String reviewerName;
  final String? reviewerAvatar;
  final String content;
  final int rating;
  final DateTime createdAt;

  const FeedbackModel({
    required this.id,
    required this.reviewerName,
    this.reviewerAvatar,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
    id:             json['id'] as int,
    reviewerName:   json['reviewerName'] as String? ?? '',
    reviewerAvatar: json['reviewerAvatar'] as String?,
    content:        json['content'] as String,
    rating:         json['rating'] as int? ?? 0,
    createdAt:      DateTime.parse(json['createdAt'] as String),
  );
}
