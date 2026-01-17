import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/professional_widgets.dart';
import '../../widgets/chart_widgets.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  State<EnhancedDashboardScreen> createState() =>
      _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<StudentProvider>().loadStudents();
        context.read<ClassProvider>().loadClasses();
        context.read<AttendanceProvider>().loadAllAttendance();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(context),
            const SizedBox(height: AppPadding.xl),
            _buildQuickStatsSection(context),
            const SizedBox(height: AppPadding.xl),
            _buildPerformanceOverviewSection(context),
            const SizedBox(height: AppPadding.xl),
            _buildChartsSection(context),
            const SizedBox(height: AppPadding.xl),
            _buildRecentActivitySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 18) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: const EdgeInsets.all(AppPadding.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppPadding.sm),
          Text(
            'Welcome back to School Management System',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppPadding.lg),
        Consumer3<StudentProvider, ClassProvider, AttendanceProvider>(
          builder:
              (context, studentProvider, classProvider, attendanceProvider, _) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppPadding.lg,
                  crossAxisSpacing: AppPadding.lg,
                  children: [
                    StatCard(
                      title: 'Total Students',
                      value: studentProvider.students.length.toString(),
                      icon: Icons.school,
                      color: AppColors.primary,
                      onTap: () => Navigator.pushNamed(context, '/students'),
                    ),
                    StatCard(
                      title: 'Total Classes',
                      value: classProvider.classes.length.toString(),
                      icon: Icons.class_,
                      color: AppColors.secondary,
                      onTap: () => Navigator.pushNamed(context, '/classes'),
                    ),
                    StatCard(
                      title: 'Attendance Rate',
                      value: _calculateAverageAttendance(attendanceProvider),
                      icon: Icons.check_circle,
                      color: AppColors.success,
                    ),
                    StatCard(
                      title: 'Active Classes',
                      value: classProvider.classes.length.toString(),
                      icon: Icons.group,
                      color: AppColors.accent,
                    ),
                  ],
                );
              },
        ),
      ],
    );
  }

  Widget _buildPerformanceOverviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppPadding.lg),
        Consumer2<StudentProvider, AnalyticsProvider>(
          builder: (context, studentProvider, analyticsProvider, _) {
            final analytics = analyticsProvider.getClassAnalytics(
              studentProvider.students,
            );

            return ProfessionalCard(
              child: Column(
                children: [
                  _buildPerformanceRow(
                    'Average GPA',
                    ((analytics['averageGPA'] as double?) ?? 0.0).toStringAsFixed(2),
                    AppColors.primary,
                  ),
                  const Divider(height: AppPadding.lg),
                  _buildPerformanceRow(
                    'Excellent Performers',
                    '${analytics['excellentCount']} students',
                    AppColors.success,
                  ),
                  const Divider(height: AppPadding.lg),
                  _buildPerformanceRow(
                    'Performance Rate',
                    '${((analytics['performancePercentage'] as double?) ?? 0.0).toStringAsFixed(1)}%',
                    AppColors.accent,
                  ),
                  const Divider(height: AppPadding.lg),
                  _buildPerformanceRow(
                    'Top Student',
                    analytics['topStudent'] ?? 'N/A',
                    AppColors.secondary,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPerformanceRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.md,
            vertical: AppPadding.xs,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: AppPadding.lg),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppPadding.lg,
          crossAxisSpacing: AppPadding.lg,
          children: [
            _buildActionCard(
              context,
              'Add Student',
              Icons.person_add,
              AppColors.primary,
              () => Navigator.pushNamed(context, '/add-student'),
            ),
            _buildActionCard(
              context,
              'Mark Attendance',
              Icons.check_circle,
              AppColors.success,
              () => Navigator.pushNamed(context, '/attendance'),
            ),
            _buildActionCard(
              context,
              'View Reports',
              Icons.assessment,
              AppColors.secondary,
              () => Navigator.pushNamed(context, '/reports'),
            ),
            _buildActionCard(
              context,
              'Manage Classes',
              Icons.class_,
              AppColors.accent,
              () => Navigator.pushNamed(context, '/classes'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: AppPadding.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateAverageAttendance(AttendanceProvider provider) {
    if (provider.attendances.isEmpty) return '0%';
    final presentCount = provider.attendances
        .where((a) => a.status == 'present')
        .length;
    final percentage = (presentCount / provider.attendances.length) * 100;
    return '${percentage.toStringAsFixed(1)}%';
  }

  Widget _buildChartsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics & Trends',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppPadding.lg),
        Consumer3<StudentProvider, AttendanceProvider, AnalyticsProvider>(
          builder: (context, studentProvider, attendanceProvider,
              analyticsProvider, _) {
            final attendanceTrend = analyticsProvider.getAttendanceTrend(
              attendanceProvider.attendances,
              7,
            );
            final gpaDistribution = analyticsProvider.getGPADistribution(
              studentProvider.students,
            );
            final performanceDistribution =
                analyticsProvider.getPerformanceDistribution(
              studentProvider.students,
            );
            final subjectAverages = analyticsProvider.getClassSubjectAverages(
              studentProvider.students,
            );

            return Column(
              children: [
                if (attendanceTrend.isNotEmpty) ...[
                  ProfessionalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Trend (Last 7 Days)',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppPadding.md),
                        AttendanceTrendChart(
                          attendanceData: attendanceTrend,
                          days: 7,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppPadding.lg),
                ],
                if (gpaDistribution.values.any((v) => v > 0)) ...[
                  ProfessionalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GPA Distribution',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppPadding.md),
                        GPADistributionChart(
                          gpaDistribution: gpaDistribution,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppPadding.lg),
                ],
                if (performanceDistribution.values.any((v) => v > 0)) ...[
                  ProfessionalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Overview',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppPadding.md),
                        PerformancePieChart(
                          performanceData: performanceDistribution,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppPadding.lg),
                ],
                if (subjectAverages.isNotEmpty) ...[
                  ProfessionalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subject Performance',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppPadding.md),
                        SubjectPerformanceChart(
                          subjectAverages: subjectAverages,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
