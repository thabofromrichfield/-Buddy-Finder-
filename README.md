# Buddy Finder

Find your people. Study better. Succeed together.

Buddy Finder is a student-focused platform for university and college students to discover compatible study partners at their institution, connect through study requests, and organise study sessions.

## The problem

Students often want to study with classmates, prepare for exams together, or get help with specific modules—but may not know who else studies the same subjects or is available.

## The solution

Buddy Finder helps students find peers based on their institution, course, year of study, modules, study preferences, and availability. It is designed as a focused academic tool, not another social media feed.

## How it works

1. Sign up with Firebase Authentication and create a student profile.
2. Add institution, course, year, modules, study style, and availability.
3. Discover students at the same institution, with filters for modules or subjects.
4. Review compatibility rankings based on shared modules and preferences.
5. Send a study request; the recipient can accept or decline.
6. Once connected, arrange a study session by creating or joining one.

## MVP scope

- Student profiles
- Discover and filter students by module or subject
- Compatibility-based matching
- Study requests and connections
- Create and join study sessions
- Privacy controls, blocking, and reporting

The initial release is focused on one institution to build a useful student community before expanding. It will not include a public feed or built-in chat.

## Technology

- Flutter mobile app
- Firebase Authentication for accounts
- Cloud Firestore for student profiles, matching data, requests, and study sessions

## Product principles

- Keep the experience focused on studying and finding compatible peers.
- Give students control over what profile information they share.
- Make blocking and reporting accessible.
- Avoid collecting or exposing unnecessary personal data.
- Build a strong community at one institution before expanding.

## Suggested core data

These are logical MVP entities; the concrete Firestore schema and security rules should be designed before connecting a production Firebase project.

- `users`: account identity and student profile fields
- `studyRequests`: sender, recipient, status, and timestamps
- `connections`: accepted study-partner relationships
- `studySessions`: creator, participants, module, time, and meeting details
- `userBlocks` / `userReports`: privacy and safety actions

Firestore Security Rules must ensure that users can only read and update permitted records, and that private profile fields are not exposed to unrelated students.

## Getting started

The repository is currently at the product-definition stage. Flutter app scaffolding, Firebase project configuration, Firestore schema, and Security Rules still need to be added. Never commit Firebase service-account credentials or other secrets.

## Vision

Finding a study partner who shares your modules and goals should be simple. Buddy Finder helps students find their people, study better, and succeed together.
