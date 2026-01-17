import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/professional_widgets.dart';

class EnhancedStudentListScreen extends StatefulWidget {
  const EnhancedStudentListScreen({super.key});

  @override
  State<EnhancedStudentListScreen> createState() =>
      _EnhancedStudentListScreenState();
}

class _EnhancedStudentListScreenState extends State<EnhancedStudentListScreen> {
  final _searchController = TextEditingController();
  String _sortBy = 'name'; // name, rollNumber, gpa
  String? _filterClass;
  bool _isAscending = true;

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

  List<Student> _getFilteredAndSortedStudents(List<Student> students) {
    var filtered = students;

    // Apply class filter
    if (_filterClass != null && _filterClass!.isNotEmpty) {
      filtered = filtered.where((s) => s.classId == _filterClass).toList();
    }

    // Apply search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (s) =>
                s.name.toLowerCase().contains(query) ||
                s.rollNumber.toLowerCase().contains(query) ||
                s.email.toLowerCase().contains(query),
          )
          .toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'rollNumber':
          comparison = a.rollNumber.compareTo(b.rollNumber);
          break;
        case 'gpa':
          final gpaA = context.read<AnalyticsProvider>().calculateGPA(a.id);
          final gpaB = context.read<AnalyticsProvider>().calculateGPA(b.id);
          comparison = gpaA.compareTo(gpaB);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });

    return filtered;
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppPadding.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter By Class',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppPadding.lg),
            Consumer<ClassProvider>(
              builder: (context, classProvider, _) {
                return ListView(
                  shrinkWrap: true,
                  children: [
                    RadioListTile(
                      title: const Text('All Classes'),
                      value: null,
                      groupValue: _filterClass,
                      onChanged: (value) {
                        setState(() => _filterClass = null);
                        Navigator.pop(context);
                      },
                    ),
                    ...classProvider.classes.map((cls) {
                      return RadioListTile(
                        title: Text(cls.name),
                        value: cls.id,
                        groupValue: _filterClass,
                        onChanged: (value) {
                          setState(() => _filterClass = value);
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students Management'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          SearchFilterBar(
            hintText: 'Search by name, roll number, email...',
            onSearch: (query) => setState(() {}),
            onFilterPressed: _showFilterOptions,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.lg),
            child: Row(
              children: [
                Chip(
                  label: Text(
                    _sortBy == 'name'
                        ? 'Sort: Name'
                        : _sortBy == 'rollNumber'
                        ? 'Sort: Roll#'
                        : 'Sort: GPA',
                  ),
                  onDeleted: () => setState(() => _sortBy = 'name'),
                ),
                if (_filterClass != null) ...[
                  const SizedBox(width: AppPadding.md),
                  Chip(
                    label: Text(
                      'Class: ${_filterClass?.substring(0, 3) ?? 'All'}',
                    ),
                    onDeleted: () => setState(() => _filterClass = null),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppPadding.md),
          Expanded(
            child: Consumer2<StudentProvider, AnalyticsProvider>(
              builder: (context, studentProvider, analyticsProvider, _) {
                if (studentProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredStudents = _getFilteredAndSortedStudents(
                  studentProvider.students,
                );

                if (filteredStudents.isEmpty) {
                  return EmptyStateWidget(
                    title: 'No Students Found',
                    subtitle: _searchController.text.isNotEmpty
                        ? 'Try adjusting your search criteria'
                        : 'Add your first student to get started',
                    icon: Icons.person_add,
                    onRetry: () => setState(() {}),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await studentProvider.loadStudents();
                    await context.read<ClassProvider>().loadClasses();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppPadding.lg),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      final gpa = analyticsProvider.calculateGPA(student.id);
                      return _buildSlidableStudentCard(context, student, gpa, studentProvider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-student'),
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),
    );
  }

  Widget _buildSlidableStudentCard(
    BuildContext context,
    Student student,
    double gpa,
    StudentProvider studentProvider,
  ) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Navigator.pushNamed(
                context,
                '/edit-student',
                arguments: student.id,
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) {
              _confirmDelete(context, student.id, studentProvider);
            },
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: _buildEnhancedStudentCard(context, student, gpa),
    );
  }

  Widget _buildEnhancedStudentCard(
    BuildContext context,
    Student student,
    double gpa,
  ) {
    return ProfessionalCard(
      onTap: () => Navigator.pushNamed(
        context,
        '/student-detail',
        arguments: student.id,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    student.name.isNotEmpty
                        ? student.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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
                      student.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Roll: ${student.rollNumber}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('View Details'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/student-detail',
                      arguments: student.id,
                    ),
                  ),
                  PopupMenuItem(
                    child: const Text('Edit'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/edit-student',
                      arguments: student,
                    ),
                  ),
                  PopupMenuItem(
                    child: const Text('Delete'),
                    onTap: () => _confirmDelete(context, student.id, null),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppPadding.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip('Class', student.classId, AppColors.info),
              _buildInfoChip('GPA', gpa.toStringAsFixed(2), _getGPAColor(gpa)),
              _buildInfoChip(
                'Email',
                student.email.split('@')[0],
                AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.md,
        vertical: AppPadding.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getGPAColor(double gpa) {
    if (gpa >= 3.5) return AppColors.success;
    if (gpa >= 3.0) return AppColors.warning;
    return AppColors.error;
  }

  void _confirmDelete(BuildContext context, String studentId, StudentProvider? studentProvider) {
    final provider = studentProvider ?? context.read<StudentProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteStudent(studentId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Student deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
