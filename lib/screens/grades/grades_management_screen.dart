import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/grade_model.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validation_utils.dart';
import '../../widgets/professional_widgets.dart';

class GradesManagementScreen extends StatefulWidget {
  final String? studentId;

  const GradesManagementScreen({this.studentId, super.key});

  @override
  State<GradesManagementScreen> createState() => _GradesManagementScreenState();
}

class _GradesManagementScreenState extends State<GradesManagementScreen> {
  final _searchController = TextEditingController();
  Student? _selectedStudent;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<StudentProvider>().loadStudents();
        if (widget.studentId != null) {
          final students = context.read<StudentProvider>().students;
          _selectedStudent = students.firstWhere(
            (s) => s.id == widget.studentId,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grades Management'),
        elevation: 0,
        centerTitle: true,
      ),
      body: _selectedStudent == null
          ? _buildStudentSelectionView(context)
          : _buildGradesView(context),
    );
  }

  Widget _buildStudentSelectionView(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, _) {
        return Column(
          children: [
            SearchFilterBar(
              hintText: 'Search students...',
              onSearch: (query) => setState(() {}),
            ),
            Expanded(
              child: studentProvider.students.isEmpty
                  ? EmptyStateWidget(
                      title: 'No Students Found',
                      subtitle: 'Add students to manage their grades',
                      icon: Icons.person_add,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppPadding.lg),
                      itemCount: studentProvider.students.length,
                      itemBuilder: (context, index) {
                        final student = studentProvider.students[index];
                        return ProfessionalCard(
                          onTap: () {
                            setState(() => _selectedStudent = student);
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text(
                                student.name.isNotEmpty ? student.name[0] : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(student.name),
                            subtitle: Text('Roll: ${student.rollNumber}'),
                            trailing: const Icon(Icons.arrow_forward),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGradesView(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, _) {
        final grades = analyticsProvider.getStudentGrades(_selectedStudent!.id);
        final subjectAverages = analyticsProvider.getSubjectAverages(
          _selectedStudent!.id,
        );
        final gpa = analyticsProvider.calculateGPA(_selectedStudent!.id);

        return SingleChildScrollView(
          child: Column(
            children: [
              // Student Header
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.all(AppPadding.lg),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _selectedStudent!.name.isNotEmpty
                              ? _selectedStudent!.name[0]
                              : '?',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppPadding.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedStudent!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Roll: ${_selectedStudent!.rollNumber}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _selectedStudent = null),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text(
                        'Change',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // GPA and Stats
              Padding(
                padding: const EdgeInsets.all(AppPadding.lg),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppPadding.lg,
                  crossAxisSpacing: AppPadding.lg,
                  children: [
                    StatCard(
                      title: 'GPA',
                      value: gpa.toStringAsFixed(2),
                      icon: Icons.star,
                      color: _getGPAColor(gpa),
                    ),
                    StatCard(
                      title: 'Total Grades',
                      value: grades.length.toString(),
                      icon: Icons.assessment,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),

              // Subject Averages
              if (subjectAverages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppPadding.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subject Averages',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppPadding.md),
                      ...subjectAverages.entries.map((entry) {
                        return _buildSubjectAverageBar(entry.key, entry.value);
                      }),
                    ],
                  ),
                ),

              // Grades List
              Padding(
                padding: const EdgeInsets.all(AppPadding.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Grades',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ProfessionalButton(
                          label: 'Add Grade',
                          onPressed: () => _showAddGradeDialog(
                            context,
                            _selectedStudent!.id,
                          ),
                          isExpanded: false,
                          icon: Icons.add,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppPadding.md),
                    if (grades.isEmpty)
                      EmptyStateWidget(
                        title: 'No Grades Yet',
                        subtitle: 'Add the first grade for this student',
                        icon: Icons.grade,
                        onRetry: () =>
                            _showAddGradeDialog(context, _selectedStudent!.id),
                      )
                    else
                      ...grades.map((grade) {
                        return _buildGradeCard(context, grade);
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubjectAverageBar(String subject, double average) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text('${average.toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: average / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getPercentageColor(average),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard(BuildContext context, Grade grade) {
    final percentage = grade.percentage;
    return ProfessionalCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getPercentageColor(percentage).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                grade.grade,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getPercentageColor(percentage),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppPadding.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade.subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${grade.marks}/${grade.maxMarks} - ${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  grade.semester,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Edit'),
                onTap: () => _showAddGradeDialog(
                  context,
                  _selectedStudent!.id,
                  grade: grade,
                ),
              ),
              PopupMenuItem(
                child: const Text('Delete'),
                onTap: () {
                  context.read<AnalyticsProvider>().deleteGrade(
                    _selectedStudent!.id,
                    grade.id,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grade deleted')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddGradeDialog(
    BuildContext context,
    String studentId, {
    Grade? grade,
  }) {
    final subjectController = TextEditingController(text: grade?.subject ?? '');
    final marksController = TextEditingController(
      text: grade?.marks.toString() ?? '',
    );
    final maxMarksController = TextEditingController(
      text: grade?.maxMarks.toString() ?? '100',
    );
    final semesterController = TextEditingController(
      text: grade?.semester ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(grade == null ? 'Add Grade' : 'Edit Grade'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Subject is required' : null,
                ),
                const SizedBox(height: AppPadding.md),
                TextFormField(
                  controller: marksController,
                  decoration: const InputDecoration(
                    labelText: 'Marks Obtained',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      ValidationUtils.validateMarks(value, maxMarks: 100),
                ),
                const SizedBox(height: AppPadding.md),
                TextFormField(
                  controller: maxMarksController,
                  decoration: const InputDecoration(labelText: 'Max Marks'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppPadding.md),
                TextFormField(
                  controller: semesterController,
                  decoration: const InputDecoration(labelText: 'Semester'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Semester is required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newGrade = Grade(
                  id: grade?.id ?? DateTime.now().toString(),
                  studentId: studentId,
                  subject: subjectController.text,
                  marks: double.parse(marksController.text),
                  maxMarks: double.parse(maxMarksController.text),
                  semester: semesterController.text,
                  date: DateTime.now(),
                );

                if (grade == null) {
                  context.read<AnalyticsProvider>().addGrade(newGrade);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grade added successfully')),
                  );
                } else {
                  context.read<AnalyticsProvider>().updateGrade(
                    studentId,
                    grade.id,
                    newGrade,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grade updated successfully')),
                  );
                }

                Navigator.pop(context);
              }
            },
            child: Text(grade == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Color _getGPAColor(double gpa) {
    if (gpa >= 3.5) return AppColors.success;
    if (gpa >= 3.0) return AppColors.warning;
    if (gpa >= 2.0) return AppColors.info;
    return AppColors.error;
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 80) return AppColors.accent;
    if (percentage >= 70) return AppColors.info;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }
}
