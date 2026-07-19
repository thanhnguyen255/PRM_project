import 'package:flutter_test/flutter_test.dart';
import 'package:project/models/models.dart';

void main() {
  group('Models JSON Parsing Tests', () {
    test('UserModel.fromJson parses correctly', () {
      final json = {
        'id': 1,
        'email': 'test@example.com',
        'fullName': 'Test User',
        'role': 'Learner',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'createdAt': '2023-10-01T12:00:00Z',
        'stats': {
          'enrolledCourses': 5,
          'completedActivities': 10
        }
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'Test User');
      expect(user.role, 'Learner');
      expect(user.isInstructor, false);
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.createdAt, DateTime.parse('2023-10-01T12:00:00Z'));
      expect(user.stats?.enrolledCourses, 5);
      expect(user.stats?.completedActivities, 10);
    });

    test('AuthResponse.fromJson parses correctly', () {
      final json = {
        'token': 'jwt_token_here',
        'userId': 1,
        'fullName': 'Test User',
        'role': 'Learner',
        'avatarUrl': null
      };

      final auth = AuthResponse.fromJson(json);

      expect(auth.token, 'jwt_token_here');
      expect(auth.userId, 1);
      expect(auth.fullName, 'Test User');
      expect(auth.role, 'Learner');
      expect(auth.avatarUrl, null);
    });

    test('CourseModel.fromJson parses correctly', () {
      final json = {
        'id': 10,
        'title': 'Flutter 101',
        'description': 'Learn Flutter',
        'instructorId': 2,
        'instructorName': 'John Doe',
        'progressPercent': 50.0,
        'activeClassId': 101,
        'activeClassName': 'Class A'
      };

      final course = CourseModel.fromJson(json);

      expect(course.id, 10);
      expect(course.title, 'Flutter 101');
      expect(course.description, 'Learn Flutter');
      expect(course.instructorId, 2);
      expect(course.progressPercent, 50.0);
      expect(course.activeClassId, 101);
      expect(course.activeClassName, 'Class A');
    });

    test('ProjectModel.fromJson parses correctly', () {
      final json = {
        'id': 1,
        'classId': 10,
        'title': 'Capstone Project',
        'description': 'Final project',
        'milestoneCount': 5,
        'completedMilestones': 2,
        'nextMilestoneTitle': 'Sprint 3',
        'nextMilestoneDueDate': '2023-11-01T00:00:00Z'
      };

      final project = ProjectModel.fromJson(json);

      expect(project.id, 1);
      expect(project.title, 'Capstone Project');
      expect(project.description, 'Final project');
      expect(project.classId, 10);
      expect(project.milestoneCount, 5);
      expect(project.completedMilestones, 2);
      expect(project.nextMilestoneTitle, 'Sprint 3');
      expect(project.nextMilestoneDueDate, DateTime.parse('2023-11-01T00:00:00Z'));
    });

    test('MilestoneModel.fromJson parses correctly', () {
      final json = {
        'id': 2,
        'projectId': 1,
        'projectTitle': 'Capstone',
        'title': 'Sprint 1',
        'description': 'First sprint',
        'dueDate': '2023-12-31T23:59:59Z',
        'stepNumber': 2,
        'isSubmitted': true,
        'submittedAt': '2023-12-30T10:00:00Z'
      };

      final milestone = MilestoneModel.fromJson(json);

      expect(milestone.id, 2);
      expect(milestone.projectId, 1);
      expect(milestone.projectTitle, 'Capstone');
      expect(milestone.title, 'Sprint 1');
      expect(milestone.dueDate, DateTime.parse('2023-12-31T23:59:59Z'));
      expect(milestone.stepNumber, 2);
      expect(milestone.isSubmitted, true);
      expect(milestone.submittedAt, DateTime.parse('2023-12-30T10:00:00Z'));
    });

    test('ReviewSessionModel.fromJson parses correctly', () {
      final json = {
        'id': 3,
        'classId': 10,
        'title': 'Peer Review 1',
        'startDate': '2023-10-15T09:00:00Z',
        'endDate': '2023-10-15T11:00:00Z',
        'isOpen': true,
        'myAssignmentCount': 3,
        'myCompletedCount': 1
      };

      final review = ReviewSessionModel.fromJson(json);

      expect(review.id, 3);
      expect(review.title, 'Peer Review 1');
      expect(review.isOpen, true);
      expect(review.startDate, DateTime.parse('2023-10-15T09:00:00Z'));
      expect(review.myAssignmentCount, 3);
      expect(review.myCompletedCount, 1);
    });
  });
}
