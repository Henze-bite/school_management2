# School Management System - Quick Start Guide

## 🚀 Quick Setup

### 1. Get Dependencies
```bash
cd d:\flutter_ass\school_management
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

### 3. Login
Use any credentials:
- **Username**: admin (or teacher, or any name)
- **Password**: any password

## 📱 App Navigation

The app uses a Bottom Navigation Bar with 5 main sections:

### Dashboard (Home Icon)
- View system overview
- See total students and classes
- Quick action buttons
- Navigate to add student/class or mark attendance

### Students (Person Icon)
- View all students
- Search by name, roll number, or email
- Sort by name, roll number, or class
- Add new student
- Edit student details
- Delete student
- View full student profile

### Classes (Class Icon)
- View all classes
- See class capacity and teacher
- Add new class
- Edit class details
- Delete class

### Attendance (Check Mark Icon)
- Select date for attendance
- Choose class
- Mark students as Present, Absent, or Leave
- Submit attendance records

### Profile (Account Icon)
- View user information
- Toggle dark/light mode
- Logout

## 🎯 Common Tasks

### Add a New Student
1. Go to **Students** tab
2. Click the **"+"** button (or "Add Student" on Dashboard)
3. Fill in all required fields:
   - Student Name
   - Roll Number
   - Select Class
   - Email
   - Phone Number
   - Date of Birth
   - Address
   - Parent Name
   - Parent Phone
4. Click **"Add Student"**

### Add a New Class
1. Go to **Classes** tab
2. Click the **"+"** button (or "Add Class" on Dashboard)
3. Enter:
   - Class Name (e.g., Class A, Grade 10)
   - Section (e.g., A, B, C)
   - Capacity (number of students)
4. Click **"Add Class"**

### Mark Attendance
1. Go to **Attendance** tab
2. Pick a date from the calendar
3. Select a class
4. For each student, mark as:
   - **Present** - Student was in class
   - **Absent** - Student was not in class
   - **Leave** - Student had approved leave
5. Click **"Submit Attendance"**

### Search for a Student
1. Go to **Students** tab
2. Use the search box at the top
3. Type student name, roll number, or email
4. Results update as you type
5. Click **Clear** to reset

### Sort Students
1. Go to **Students** tab
2. Click the **Sort** icon (top-right)
3. Choose sorting option:
   - **By Name** - Alphabetical order
   - **By Roll Number** - Numerical order
   - **By Class** - Grouped by class

### View Student Details
1. Go to **Students** tab
2. Find the student and tap on menu (three dots)
3. Click **"View"**
4. See all student information
5. Can edit or delete from here

### Edit Student Information
1. Find the student (in Students tab)
2. Tap menu (three dots) → **"Edit"**
3. Modify any fields
4. Click **"Update Student"**

### Toggle Dark Mode
1. Go to **Profile** tab
2. Find **"Dark Mode"** toggle
3. Switch ON/OFF

## 📊 Database Structure

The app automatically creates a local SQLite database with these tables:

- **users**: Login information
- **students**: Student details
- **classes**: Class information
- **attendance**: Attendance records

All data is stored locally on your device. No internet required!

## ⚙️ Technical Details

- **Framework**: Flutter
- **Language**: Dart
- **Database**: SQLite (Local)
- **State Management**: Provider
- **Design**: Material Design 3
- **Architecture**: Clean Architecture

## 🔐 Features

✅ User Authentication
✅ Student CRUD Operations
✅ Class Management
✅ Attendance Tracking
✅ Search & Filter
✅ Dark/Light Mode
✅ Form Validation
✅ Error Handling
✅ Responsive UI
✅ Offline Functionality

## 📝 Data Validation

The app validates all inputs:

- **Names**: Cannot be empty
- **Numbers**: Must be numeric where required
- **Email**: Basic format validation
- **Dates**: Must be valid date format
- **Classes**: Must select at least one

## 🆘 Troubleshooting

### App crashes on startup
```bash
flutter clean
flutter pub get
flutter run
```

### Database not saving data
- Check app has proper permissions
- Try clearing app data and reinstalling
- Check device storage space

### Search not working
- Make sure students exist
- Check exact spelling
- Try different search terms

### Attendance not marking
- Ensure class is selected
- Check all students are loaded
- Try selecting a different date

## 💡 Tips

1. **Use Admin** username for full features
2. **Sort students** regularly for organization
3. **Mark attendance daily** for accurate records
4. **Back up important data** periodically
5. **Update profiles** when student info changes
6. **Use dark mode** to save battery on OLED screens

## 🎓 Example Data

Try creating sample data to test:

**Sample Class:**
- Name: Class A
- Section: A
- Capacity: 40

**Sample Student:**
- Name: John Doe
- Roll: 001
- Email: john@school.edu
- Class: Class A
- DOB: 2010-05-15
- Address: 123 Main St
- Parent: Jane Doe
- Parent Phone: 555-1234

## 📞 Support

If you encounter issues:
1. Check this guide
2. Review error messages
3. Try the troubleshooting section
4. Check Flutter documentation

## 🔄 Future Features (Planned)

- PDF report generation
- Photo upload for students
- Notifications
- Advanced analytics
- Parent portal
- QR code attendance
- Email reports
- Multi-school support

## ✨ Best Practices

1. **Backup Data**: Regular exports
2. **Keep Updated**: Check for app updates
3. **Secure Passwords**: Use strong credentials
4. **Regular Maintenance**: Delete old unused records
5. **Proper Organization**: Use clear naming conventions

---

**Happy Teaching & Learning! 🎉**
