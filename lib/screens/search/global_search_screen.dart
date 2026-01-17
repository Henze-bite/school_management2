import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/professional_widgets.dart';
import '../../models/student_model.dart';
import '../../models/class_model.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all'; // all, students, classes, grades

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<StudentProvider>().loadStudents();
        context.read<ClassProvider>().loadClasses();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Student> _searchStudents(String query) {
    if (query.isEmpty) return [];
    final students = context.read<StudentProvider>().students;
    final lowerQuery = query.toLowerCase();
    return students.where((student) {
      return student.name.toLowerCase().contains(lowerQuery) ||
          student.rollNumber.toLowerCase().contains(lowerQuery) ||
          student.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<SchoolClass> _searchClasses(String query) {
    if (query.isEmpty) return [];
    final classes = context.read<ClassProvider>().classes;
    final lowerQuery = query.toLowerCase();
    return classes.where((cls) {
      return cls.name.toLowerCase().contains(lowerQuery) ||
          cls.section.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Map<String, dynamic>> _searchGrades(String query) {
    if (query.isEmpty) return [];
    final analyticsProvider = context.read<AnalyticsProvider>();
    final students = context.read<StudentProvider>().students;
    final results = <Map<String, dynamic>>[];
    final lowerQuery = query.toLowerCase();

    for (final student in students) {
      final grades = analyticsProvider.getStudentGrades(student.id);
      for (final grade in grades) {
        if (grade.subject.toLowerCase().contains(lowerQuery) ||
            student.name.toLowerCase().contains(lowerQuery)) {
          results.add({
            'student': student,
            'grade': grade,
          });
        }
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppPadding.lg),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search students, classes, grades...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: AppPadding.md),
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('All', 'all'),
                      const SizedBox(width: AppPadding.sm),
                      _buildCategoryChip('Students', 'students'),
                      const SizedBox(width: AppPadding.sm),
                      _buildCategoryChip('Classes', 'classes'),
                      const SizedBox(width: AppPadding.sm),
                      _buildCategoryChip('Grades', 'grades'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Results
          Expanded(
            child: _searchQuery.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: AppColors.textGrey.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppPadding.lg),
                        Text(
                          'Start typing to search',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = value;
        });
      },
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    return Consumer3<StudentProvider, ClassProvider, AnalyticsProvider>(
      builder: (context, studentProvider, classProvider, analyticsProvider, _) {
        final students = _selectedCategory == 'all' || _selectedCategory == 'students'
            ? _searchStudents(_searchQuery)
            : [];
        final classes = _selectedCategory == 'all' || _selectedCategory == 'classes'
            ? _searchClasses(_searchQuery)
            : [];
        final grades = _selectedCategory == 'all' || _selectedCategory == 'grades'
            ? _searchGrades(_searchQuery)
            : [];

        if (students.isEmpty && classes.isEmpty && grades.isEmpty) {
          return EmptyStateWidget(
            title: 'No Results Found',
            subtitle: 'Try adjusting your search query',
            icon: Icons.search_off,
          );
        }

        return ListView(
          padding: const EdgeInsets.all(AppPadding.lg),
          children: [
            if (students.isNotEmpty) ...[
              _buildSectionHeader('Students (${students.length})'),
              const SizedBox(height: AppPadding.md),
              ...students.map((student) => _buildStudentResult(student)),
              const SizedBox(height: AppPadding.lg),
            ],
            if (classes.isNotEmpty) ...[
              _buildSectionHeader('Classes (${classes.length})'),
              const SizedBox(height: AppPadding.md),
              ...classes.map((cls) => _buildClassResult(cls)),
              const SizedBox(height: AppPadding.lg),
            ],
            if (grades.isNotEmpty) ...[
              _buildSectionHeader('Grades (${grades.length})'),
              const SizedBox(height: AppPadding.md),
              ...grades.map((item) => _buildGradeResult(item)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
    );
  }

  Widget _buildStudentResult(Student student) {
    final gpa = context.read<AnalyticsProvider>().calculateGPA(student.id);
    return ProfessionalCard(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/student-detail',
          arguments: student.id,
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: Text(
            student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
        title: Text(student.name),
        subtitle: Text('Roll: ${student.rollNumber} | GPA: ${gpa.toStringAsFixed(2)}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildClassResult(SchoolClass schoolClass) {
    return ProfessionalCard(
      onTap: () {
        Navigator.pushNamed(context, '/classes');
      },
      child: ListTile(
        leading: const Icon(Icons.class_, color: AppColors.secondary),
        title: Text('${schoolClass.name} - ${schoolClass.section}'),
        subtitle: Text('Capacity: ${schoolClass.capacity}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildGradeResult(Map<String, dynamic> item) {
    final student = item['student'] as Student;
    final grade = item['grade'];
    return ProfessionalCard(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/student-detail',
          arguments: student.id,
        );
      },
      child: ListTile(
        leading: const Icon(Icons.grade, color: AppColors.accent),
        title: Text('${student.name} - ${grade.subject}'),
        subtitle: Text('Marks: ${grade.marks}/${grade.maxMarks} (${grade.percentage.toStringAsFixed(1)}%)'),
        trailing: Text(
          grade.grade,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}

