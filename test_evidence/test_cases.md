# Test Cases: Learner App (SCR-L1 to SCR-L32)

| Screen ID | Screen Name | Scenario (Happy Path / Error Path) | Expected Result |
| :--- | :--- | :--- | :--- |
| **SCR-L01** | Splash Screen | **Happy Path:** Valid token exists | Redirects to Home Dashboard (SCR-L05) |
| | | **Error Path:** No token or invalid token | Redirects to Login Screen (SCR-L02) |
| **SCR-L02** | Login Screen | **Happy Path:** Correct email and password | Login successful, redirects to Dashboard, saves token |
| | | **Error Path:** Incorrect credentials | Displays error message "Invalid email or password" |
| **SCR-L03** | Register Screen | **Happy Path:** All valid fields | Account created, redirects to Login |
| | | **Error Path:** Email already exists | Displays error "Email is already registered" |
| **SCR-L04** | Forgot Password | **Happy Path:** Valid email | Sends password reset email/link |
| | | **Error Path:** Unregistered email | Displays error "Email not found" |
| **SCR-L05** | Home Dashboard | **Happy Path:** Data loads successfully | Displays learning activities, progress, and upcoming tasks |
| **SCR-L06** | Notifications | **Happy Path:** User has notifications | Displays list of notifications |
| **SCR-L07** | My Courses | **Happy Path:** User enrolled in courses | Displays list of enrolled courses |
| **SCR-L08** | Course Detail | **Happy Path:** Click on a course | Displays course information and syllabus |
| **SCR-L09** | Class Detail | **Happy Path:** Select a class | Displays class info, instructor, and schedule |
| **SCR-L10** | Members List | **Happy Path:** View class members | Displays list of classmates and instructor |
| **SCR-L11** | Learning Path Overview | **Happy Path:** Navigate to learning path | Displays weeks/modules |
| **SCR-L12** | Week Detail | **Happy Path:** Select a week | Displays activities and materials for that week |
| **SCR-L13** | Materials List | **Happy Path:** View materials | Displays documents, videos, etc. |
| **SCR-L14** | Material Detail | **Happy Path:** Select material | Displays material metadata |
| **SCR-L15** | Video Player | **Happy Path:** Play video | Video plays successfully |
| **SCR-L16** | Document Viewer | **Happy Path:** Open PDF/Doc | Document renders successfully |
| **SCR-L17** | Pre-Class Activities | **Happy Path:** Load pre-class list | Displays pending/completed pre-class activities |
| **SCR-L18** | Pre-Class Activity Detail | **Happy Path:** View details | Shows instructions and requirements |
| **SCR-L19** | Submit Evidence (Pre) | **Happy Path:** Upload valid evidence | Evidence submitted successfully, status changes |
| | | **Error Path:** Upload fails / file too large | Shows error message |
| **SCR-L20** | In-Class Activities | **Happy Path:** Load in-class list | Displays activities |
| **SCR-L21** | In-Class Activity Detail | **Happy Path:** View details | Shows activity requirements |
| **SCR-L22** | Submit Evidence (In) | **Happy Path:** Upload evidence | Submitted successfully |
| **SCR-L23** | Post-Class Activities | **Happy Path:** Load post-class list | Displays tasks |
| **SCR-L24** | Post-Class Activity Detail| **Happy Path:** View details | Shows requirements |
| **SCR-L25** | Submit Evidence (Post) | **Happy Path:** Upload reflection/evidence | Submitted successfully |
| **SCR-L26** | Project List | **Happy Path:** View assigned projects | Displays project list |
| **SCR-L27** | Project Detail | **Happy Path:** Select project | Shows project info and group members |
| **SCR-L28** | Milestone List | **Happy Path:** View milestones | Shows milestones and deadlines |
| **SCR-L29** | Milestone Detail | **Happy Path:** View milestone | Shows detailed requirements |
| **SCR-L30** | Submit Milestone | **Happy Path:** Upload file | Milestone submitted successfully |
| **SCR-L31** | Review Sessions | **Happy Path:** View review sessions | Shows pending and completed reviews |
| **SCR-L32** | Review Detail | **Happy Path:** View review reqs | Shows what needs to be reviewed |
