USE FlippedClassroomDB;

-- Clear data to prevent duplicates on rerun
DELETE FROM Notifications;
DELETE FROM Feedbacks;
DELETE FROM ReviewAssignments;
DELETE FROM ReviewSessions;
DELETE FROM MilestoneSubmissions;
DELETE FROM Milestones;
DELETE FROM Projects;
DELETE FROM EvidenceComments;
DELETE FROM ActivitySubmissions;
DELETE FROM Activities;
DELETE FROM LearningMaterials;
DELETE FROM LearningPaths;
DELETE FROM ClassMembers;
DELETE FROM Classes;
DELETE FROM Courses;
DELETE FROM Users;

-- Users
SET IDENTITY_INSERT Users ON;
INSERT INTO Users (Id, Email, PasswordHash, FullName, AvatarUrl, Role, CreatedAt)
VALUES 
(1, 'instructor@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', 'Test Instructor', 'https://i.pravatar.cc/150?u=instructor', 1, GETDATE()),
(2, 'learner@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', 'Test Learner', 'https://i.pravatar.cc/150?u=learner', 0, GETDATE()),
(3, 'learner2@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', 'Alice Learner', 'https://i.pravatar.cc/150?u=alice', 0, GETDATE()),
(4, 'learner3@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', 'Bob Learner', 'https://i.pravatar.cc/150?u=bob', 0, GETDATE());
SET IDENTITY_INSERT Users OFF;

-- Courses
SET IDENTITY_INSERT Courses ON;
INSERT INTO Courses (Id, InstructorId, Title, Description, CoverImageUrl, CreatedAt)
VALUES 
(1, 1, 'PRM393 - Mobile App Development', 'Advanced Flutter and Dart course.', 'https://picsum.photos/seed/prm/400/200', GETDATE()),
(2, 1, 'SWD392 - Software Architecture', 'Software architecture patterns and practices.', 'https://picsum.photos/seed/swd/400/200', GETDATE());
SET IDENTITY_INSERT Courses OFF;

-- Classes
SET IDENTITY_INSERT Classes ON;
INSERT INTO Classes (Id, CourseId, Name, StartDate, EndDate)
VALUES 
(1, 1, 'SE1601', GETDATE(), DATEADD(month, 3, GETDATE())),
(2, 1, 'SE1602', GETDATE(), DATEADD(month, 3, GETDATE())),
(3, 2, 'SE1603', GETDATE(), DATEADD(month, 3, GETDATE()));
SET IDENTITY_INSERT Classes OFF;

-- ClassMembers
SET IDENTITY_INSERT ClassMembers ON;
INSERT INTO ClassMembers (Id, ClassId, UserId, JoinedAt)
VALUES 
(1, 1, 2, GETDATE()),
(2, 1, 3, GETDATE()),
(3, 1, 4, GETDATE()),
(4, 3, 2, GETDATE());
SET IDENTITY_INSERT ClassMembers OFF;

-- LearningPaths
SET IDENTITY_INSERT LearningPaths ON;
INSERT INTO LearningPaths (Id, ClassId, Title, WeekNumber)
VALUES 
(1, 1, 'Week 1: Intro to Flutter', 1),
(2, 1, 'Week 2: State Management', 2),
(3, 1, 'Week 3: Networking', 3);
SET IDENTITY_INSERT LearningPaths OFF;

-- LearningMaterials
SET IDENTITY_INSERT LearningMaterials ON;
INSERT INTO LearningMaterials (Id, LearningPathId, Title, Type, FileUrl)
VALUES 
(1, 1, 'Flutter Intro Video', 0, 'https://www.w3schools.com/html/mov_bbb.mp4'),
(2, 1, 'Flutter Setup Guide', 1, 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'),
(3, 2, 'Provider Pattern Tutorial', 0, 'https://www.w3schools.com/html/mov_bbb.mp4');
SET IDENTITY_INSERT LearningMaterials OFF;

-- Activities
SET IDENTITY_INSERT Activities ON;
INSERT INTO Activities (Id, LearningPathId, Title, Type, Description)
VALUES 
(1, 1, 'Pre-Class Reading: Dart Basics', 0, 'Read chapter 1 and write a summary.'),
(2, 1, 'In-Class Ex: UI Layout', 1, 'Build the UI layout discussed in class.'),
(3, 1, 'Post-Class: Reflection', 2, 'Write a reflection on your learning process.'),
(4, 2, 'Pre-Class Video: Provider', 0, 'Watch the video and answer questions.');
SET IDENTITY_INSERT Activities OFF;

-- ActivitySubmissions
SET IDENTITY_INSERT ActivitySubmissions ON;
INSERT INTO ActivitySubmissions (Id, ActivityId, UserId, FileUrl, Note, Status, SubmittedAt)
VALUES 
(1, 1, 2, 'https://example.com/summary.pdf', 'Here is my summary.', 1, GETDATE()),
(2, 2, 2, 'https://example.com/ui.zip', 'Completed UI.', 0, GETDATE()),
(3, 1, 3, 'https://example.com/summary_alice.pdf', 'Done.', 1, GETDATE());
SET IDENTITY_INSERT ActivitySubmissions OFF;

-- EvidenceComments
SET IDENTITY_INSERT EvidenceComments ON;
INSERT INTO EvidenceComments (Id, SubmissionId, UserId, Content, CreatedAt)
VALUES 
(1, 1, 1, 'Good summary!', GETDATE()),
(2, 1, 2, 'Thank you!', GETDATE());
SET IDENTITY_INSERT EvidenceComments OFF;

-- Projects
SET IDENTITY_INSERT Projects ON;
INSERT INTO Projects (Id, ClassId, Title, Description)
VALUES 
(1, 1, 'Final Project: E-Commerce App', 'Build a full e-commerce app with Flutter and ASP.NET Core.');
SET IDENTITY_INSERT Projects OFF;

-- Milestones
SET IDENTITY_INSERT Milestones ON;
INSERT INTO Milestones (Id, ProjectId, Title, Description, DueDate)
VALUES 
(1, 1, 'Milestone 1: UI Mockup', 'Design the UI in Figma.', DATEADD(day, 14, GETDATE())),
(2, 1, 'Milestone 2: App Prototype', 'Build the basic screens.', DATEADD(day, 30, GETDATE())),
(3, 1, 'Milestone 3: Final Delivery', 'Complete the app.', DATEADD(day, 60, GETDATE()));
SET IDENTITY_INSERT Milestones OFF;

-- MilestoneSubmissions
SET IDENTITY_INSERT MilestoneSubmissions ON;
INSERT INTO MilestoneSubmissions (Id, MilestoneId, UserId, FileUrl, Description, SubmittedAt)
VALUES 
(1, 1, 2, 'https://figma.com/file', 'Figma link attached.', GETDATE());
SET IDENTITY_INSERT MilestoneSubmissions OFF;

-- ReviewSessions
SET IDENTITY_INSERT ReviewSessions ON;
INSERT INTO ReviewSessions (Id, ClassId, ActivityId, Title, StartDate, EndDate)
VALUES 
(1, 1, 2, 'Midterm Peer Review', DATEADD(day, 15, GETDATE()), DATEADD(day, 20, GETDATE()));
SET IDENTITY_INSERT ReviewSessions OFF;

-- ReviewAssignments
SET IDENTITY_INSERT ReviewAssignments ON;
INSERT INTO ReviewAssignments (Id, SessionId, ReviewerId, RevieweeId)
VALUES 
(1, 1, 2, 3),
(2, 1, 3, 2),
(3, 1, 4, 2);
SET IDENTITY_INSERT ReviewAssignments OFF;

-- Feedbacks
SET IDENTITY_INSERT Feedbacks ON;
INSERT INTO Feedbacks (Id, AssignmentId, Content, Rating, CreatedAt)
VALUES 
(1, 1, 'Great code quality but lacks comments.', 4, GETDATE()),
(2, 2, 'Excellent UI design.', 5, GETDATE());
SET IDENTITY_INSERT Feedbacks OFF;

-- Notifications
SET IDENTITY_INSERT Notifications ON;
INSERT INTO Notifications (Id, UserId, Title, Body, IsRead, CreatedAt)
VALUES 
(1, 2, 'Welcome to PRM393', 'Your class SE1601 has started.', 0, GETDATE()),
(2, 2, 'New Activity', 'You have a new Pre-class activity.', 0, GETDATE()),
(3, 1, 'Submission Received', 'Test Learner submitted an activity.', 1, GETDATE());
SET IDENTITY_INSERT Notifications OFF;
