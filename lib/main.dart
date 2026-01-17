import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/class_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/analytics_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard/enhanced_dashboard_screen.dart';
import 'screens/student/enhanced_student_list_screen.dart';
import 'screens/student/student_detail_screen.dart';
import 'screens/student/add_edit_student_screen.dart';
import 'screens/class/class_list_screen.dart';
import 'screens/class/add_edit_class_screen.dart';
import 'screens/attendance/attendance_screen.dart';
import 'screens/attendance/attendance_calendar_screen.dart';
import 'screens/grades/grades_management_screen.dart';
import 'screens/search/global_search_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/timetable/timetable_screen.dart';
import 'screens/fees/fee_management_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'School Management System',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            darkTheme: themeProvider.themeData,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashScreen(),
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/dashboard': (context) => const EnhancedDashboardScreen(),
              '/students': (context) => const EnhancedStudentListScreen(),
              '/student-detail': (context) => StudentDetailScreen(
                studentId:
                    ModalRoute.of(context)?.settings.arguments as String? ?? '',
              ),
              '/add-student': (context) => const AddEditStudentScreen(),
              '/edit-student': (context) => AddEditStudentScreen(
                studentId:
                    ModalRoute.of(context)?.settings.arguments as String?,
              ),
              '/classes': (context) => const ClassListScreen(),
              '/add-class': (context) => const AddEditClassScreen(),
              '/edit-class': (context) => AddEditClassScreen(
                classId: ModalRoute.of(context)?.settings.arguments as String?,
              ),
              '/attendance': (context) => const AttendanceScreen(),
              '/attendance-calendar': (context) => const AttendanceCalendarScreen(),
              '/grades': (context) => const GradesManagementScreen(),
              '/reports': (context) => const GradesManagementScreen(),
              '/search': (context) => const GlobalSearchScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/timetable': (context) => const TimetableScreen(),
              '/fees': (context) => const FeeManagementScreen(),
            },
          );
        },
      ),
    );
  }
}
