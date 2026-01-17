import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fee_model.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/professional_widgets.dart';
import 'package:intl/intl.dart';

class FeeManagementScreen extends StatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  State<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends State<FeeManagementScreen> {
  String? _selectedClassId;
  String? _selectedStudentId;
  String _filterStatus = 'all'; // all, pending, paid, overdue
  final List<Fee> _fees = [];

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

  List<Fee> _getFilteredFees() {
    var filtered = _fees;
    
    if (_selectedClassId != null) {
      filtered = filtered.where((f) => f.classId == _selectedClassId).toList();
    }
    
    if (_selectedStudentId != null) {
      filtered = filtered.where((f) => f.studentId == _selectedStudentId).toList();
    }
    
    if (_filterStatus != 'all') {
      filtered = filtered.where((f) => f.status == _filterStatus).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Management'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddFeeDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(AppPadding.lg),
            child: Column(
              children: [
                ProfessionalCard(
                  child: Column(
                    children: [
                      Consumer<ClassProvider>(
                        builder: (context, classProvider, _) {
                          return DropdownButtonFormField<String>(
                            value: _selectedClassId,
                            decoration: InputDecoration(
                              labelText: 'Filter by Class',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('All Classes'),
                              ),
                              ...classProvider.classes.map((cls) {
                                return DropdownMenuItem<String>(
                                  value: cls.id,
                                  child: Text('${cls.name} - ${cls.section}'),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedClassId = value;
                                _selectedStudentId = null;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: AppPadding.md),
                      Consumer<StudentProvider>(
                        builder: (context, studentProvider, _) {
                          final classStudents = _selectedClassId != null
                              ? studentProvider.students
                                  .where((s) => s.classId == _selectedClassId)
                                  .toList()
                              : studentProvider.students;
                          
                          return DropdownButtonFormField<String>(
                            value: _selectedStudentId,
                            decoration: InputDecoration(
                              labelText: 'Filter by Student',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('All Students'),
                              ),
                              ...classStudents.map((student) {
                                return DropdownMenuItem<String>(
                                  value: student.id,
                                  child: Text(student.name),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedStudentId = value;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: AppPadding.md),
                      // Status Filter
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('All'),
                              selected: _filterStatus == 'all',
                              onSelected: (selected) {
                                setState(() {
                                  _filterStatus = 'all';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: AppPadding.sm),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Pending'),
                              selected: _filterStatus == 'pending',
                              onSelected: (selected) {
                                setState(() {
                                  _filterStatus = 'pending';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: AppPadding.sm),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Paid'),
                              selected: _filterStatus == 'paid',
                              onSelected: (selected) {
                                setState(() {
                                  _filterStatus = 'paid';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Fee List
          Expanded(
            child: _getFilteredFees().isEmpty
                ? EmptyStateWidget(
                    title: 'No Fees Found',
                    subtitle: 'Add fees to get started',
                    icon: Icons.payment,
                    onRetry: () => _showAddFeeDialog(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppPadding.lg),
                    itemCount: _getFilteredFees().length,
                    itemBuilder: (context, index) {
                      final fee = _getFilteredFees()[index];
                      return _buildFeeCard(fee);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeCard(Fee fee) {
    final student = context.read<StudentProvider>().students
        .firstWhere((s) => s.id == fee.studentId, orElse: () => Student(
          id: '',
          name: 'Unknown',
          rollNumber: '',
          classId: '',
          email: '',
          phone: '',
          dateOfBirth: '',
          address: '',
          parentName: '',
          parentPhone: '',
        ));

    Color statusColor;
    switch (fee.status) {
      case 'paid':
        statusColor = AppColors.success;
        break;
      case 'overdue':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return ProfessionalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                      '${fee.feeType} - ${fee.classId}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textGrey,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.md,
                  vertical: AppPadding.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  fee.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppPadding.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textGrey,
                        ),
                  ),
                  Text(
                    '\$${fee.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Due Date',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textGrey,
                        ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(fee.dueDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          if (fee.status == 'paid' && fee.paidDate != null) ...[
            const SizedBox(height: AppPadding.sm),
            Text(
              'Paid on: ${DateFormat('MMM dd, yyyy').format(fee.paidDate!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                  ),
            ),
          ],
          const SizedBox(height: AppPadding.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (fee.status != 'paid')
                TextButton.icon(
                  onPressed: () => _markAsPaid(fee),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Paid'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.success,
                  ),
                ),
              const SizedBox(width: AppPadding.sm),
              TextButton.icon(
                onPressed: () => _generateReceipt(fee),
                icon: const Icon(Icons.receipt),
                label: const Text('Receipt'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddFeeDialog() {
    final formKey = GlobalKey<FormState>();
    String? selectedStudentId;
    String? selectedClassId;
    double? amount;
    String? feeType;
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Fee'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<ClassProvider>(
                  builder: (context, classProvider, _) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Class'),
                      items: classProvider.classes.map((cls) {
                        return DropdownMenuItem(
                          value: cls.id,
                          child: Text('${cls.name} - ${cls.section}'),
                        );
                      }).toList(),
                      onChanged: (value) => selectedClassId = value,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<StudentProvider>(
                  builder: (context, studentProvider, _) {
                    final students = selectedClassId != null
                        ? studentProvider.students
                            .where((s) => s.classId == selectedClassId)
                            .toList()
                        : studentProvider.students;
                    
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Student'),
                      items: students.map((student) {
                        return DropdownMenuItem(
                          value: student.id,
                          child: Text(student.name),
                        );
                      }).toList(),
                      onChanged: (value) => selectedStudentId = value,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Fee Type'),
                  onChanged: (value) => feeType = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => amount = double.tryParse(value),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      dueDate = picked;
                    }
                  },
                  child: Text(
                    dueDate != null
                        ? DateFormat('MMM dd, yyyy').format(dueDate!)
                        : 'Select Due Date',
                  ),
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
              if (formKey.currentState!.validate() &&
                  selectedStudentId != null &&
                  selectedClassId != null &&
                  amount != null &&
                  feeType != null &&
                  dueDate != null) {
                final fee = Fee(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  studentId: selectedStudentId!,
                  classId: selectedClassId!,
                  amount: amount!,
                  feeType: feeType!,
                  dueDate: dueDate!,
                  status: 'pending',
                );
                setState(() {
                  _fees.add(fee);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fee added successfully')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _markAsPaid(Fee fee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: const Text('Are you sure you want to mark this fee as paid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final index = _fees.indexWhere((f) => f.id == fee.id);
                if (index != -1) {
                  _fees[index] = fee.copyWith(
                    status: 'paid',
                    paidDate: DateTime.now(),
                    receiptNumber: 'RCP-${DateTime.now().millisecondsSinceEpoch}',
                  );
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fee marked as paid')),
              );
            },
            child: const Text('Mark as Paid'),
          ),
        ],
      ),
    );
  }

  void _generateReceipt(Fee fee) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receipt generated: ${fee.receiptNumber ?? 'N/A'}'),
      ),
    );
  }
}

