# School Management System

A comprehensive Flutter-based Student Management System with features for managing students, classes, attendance, and user profiles.

## Features

### 1. **User Interface (UI)**
- ✅ Splash Screen with app logo
- ✅ Login/Logout Screen (Teacher/Admin)
- ✅ Dashboard (total students, classes, attendance overview, quick actions)
- ✅ Student List (search, filter, sort)
- ✅ Student Detail (view, edit, delete)
- ✅ Class List (add, edit, delete classes)
- ✅ Attendance Screen (mark attendance, view history)
- ✅ Profile Screen (user info, settings, dark/light mode)
- ✅ Bottom Navigation (Dashboard, Students, Classes, Attendance, Profile)

### 2. **User Features**
- ✅ Teacher/Admin login
- ✅ Add/edit/delete student records
- ✅ Add/edit/delete class records
- ✅ Search students by name, roll number, or email
- ✅ Mark and track attendance
- ✅ Sort students by name, class, or roll number
- ✅ Update profile information
- ✅ Dark/Light mode toggle

### 3. **Technical Features**
- ✅ Flutter & Dart
- ✅ Material Design
- ✅ Provider State Management
- ✅ SQLite Local Database
- ✅ Responsive UI (Mobile optimized)
- ✅ Clean Architecture
- ✅ Form Validation

### 4. **Extra Features** (Ready to Implement)
- 🔲 Student profile picture upload
- 🔲 Generate PDF attendance report
- 🔲 Notifications for attendance reminders
- 🔲 Advanced reporting

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models
│   ├── user_model.dart
│   ├── student_model.dart
│   ├── class_model.dart
│   ├── attendance_model.dart
├── providers/                         # State management
│   ├── auth_provider.dart
│   ├── student_provider.dart
│   ├── class_provider.dart
│   ├── attendance_provider.dart
│   ├── theme_provider.dart
├── services/                          # Business logic
│   ├── database_service.dart
├── screens/                           # UI screens
│   ├── auth/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   ├── student/
│   │   ├── student_list_screen.dart
│   │   ├── add_edit_student_screen.dart
│   ├── class/
│   │   ├── class_list_screen.dart
│   │   ├── add_edit_class_screen.dart
│   ├── attendance/
│   │   ├── attendance_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   └── home_screen.dart               # Bottom navigation wrapper
```

## Installation & Setup

### Prerequisites
- Flutter SDK (v3.10.3 or higher)
- Dart SDK
- Android Studio / Xcode / VS Code
- Git

### Steps

1. **Clone the repository**
   ```bash
   cd d:\flutter_ass\school_management
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Dependencies

Key packages used in this project:

```yaml
- provider: ^6.4.0                    # State management
- sqflite: ^2.3.0                     # SQLite database
- path: ^1.8.3                        # Path handling
- google_fonts: ^6.2.0                # Custom fonts
- image_picker: ^1.1.2                # Image selection
- pdf: ^3.10.8                        # PDF generation
- printing: ^5.11.3                   # Print functionality
- flutter_local_notifications: ^18.0.0 # Local notifications
- intl: ^0.19.0                       # Internationalization
- flutter_secure_storage: ^9.0.0      # Secure storage
- go_router: ^14.1.0                  # Advanced routing
```

## Usage

### Login
- **Username**: admin (or any username)
- **Password**: any password (demo mode)
- **Role**: Automatically set based on username (contains 'admin' = admin role)

### Navigation
The app uses bottom navigation to move between main screens:
1. **Dashboard** - Overview of system stats and quick actions
2. **Students** - View and manage student records
3. **Classes** - View and manage class information
4. **Attendance** - Mark and track attendance
5. **Profile** - View profile and toggle dark mode

### Key Features Usage

#### Adding a Student
1. Navigate to Students tab
2. Click the "+" button or "Add Student" button
3. Fill in all required fields
4. Select the class
5. Click "Add Student"

#### Adding a Class
1. Navigate to Classes tab
2. Click the "+" button or "Add Class" button
3. Enter class name, section, and capacity
4. Click "Add Class"

#### Marking Attendance
1. Navigate to Attendance tab
2. Select the date
3. Select a class
4. Mark each student as Present, Absent, or Leave
5. Click "Submit Attendance"

#### Searching Students
1. In Students tab, use the search bar
2. Search by student name, roll number, or email
3. Results update in real-time

#### Sorting Students
1. In Students tab, click the sort icon
2. Choose sort option: Name, Roll Number, or Class

## Database Schema

### Users Table
- id (PRIMARY KEY)
- username
- email
- role (admin/teacher)
- profileImagePath

### Classes Table
- id (PRIMARY KEY)
- name
- section
- capacity
- teacherId

### Students Table
- id (PRIMARY KEY)
- name
- rollNumber
- classId (FOREIGN KEY)
- email
- phone
- profileImagePath
- dateOfBirth
- address
- parentName
- parentPhone

### Attendance Table
- id (PRIMARY KEY)
- studentId (FOREIGN KEY)
- classId (FOREIGN KEY)
- date
- status (present/absent/leave)
- remarks

## Customization

### Change App Colors
Edit `lib/providers/theme_provider.dart` and modify the color values:
```dart
primaryColor: const Color(0xFF1E88E5),  // Change this
```

### Add More Features
The app is built with extensibility in mind. To add new features:
1. Create a new model in `lib/models/`
2. Create a provider in `lib/providers/`
3. Add database methods in `database_service.dart`
4. Create screens in `lib/screens/`
5. Add routes in `main.dart`

## Future Enhancements

- [ ] Photo upload for student profiles
- [ ] PDF attendance reports
- [ ] Push notifications for attendance
- [ ] Attendance analytics and charts
- [ ] Multiple user roles and permissions
- [ ] Cloud synchronization
- [ ] Biometric login
- [ ] QR code attendance marking
- [ ] Email notifications
- [ ] Parent portal access

## Troubleshooting

### App won't start
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `flutter run`

### Database errors
1. Delete app data: `flutter clean`
2. Reinstall: `flutter run`

### UI not rendering
1. Check if all screens are properly imported in `main.dart`
2. Verify provider setup in `MultiProvider`

## Architecture

This project follows **Clean Architecture** principles:

- **Models**: Data structures
- **Providers**: State management (ChangeNotifier pattern)
- **Services**: Database and business logic
- **Screens**: UI components

## Performance Considerations

- Uses `Provider` for efficient state management
- Implements pagination-ready code
- Optimized database queries
- Lazy loading of data

## Security Features

- Form validation on all inputs
- Secure storage option available
- Input sanitization
- Error handling and user feedback

## Contributing

To contribute to this project:
1. Create a new branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## License

This project is open source and available for educational purposes.

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review the code comments
3. Check Flutter documentation

## Version History

- **v1.0.0** - Initial Release
  - Core student management
  - Class management
  - Attendance tracking
  - User authentication
  - Dark/Light mode
  - Local database storage

---

**Built with ❤️ using Flutter**
