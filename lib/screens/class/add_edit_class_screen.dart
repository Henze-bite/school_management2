import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/class_model.dart';

class AddEditClassScreen extends StatefulWidget {
  final String? classId;

  const AddEditClassScreen({super.key, this.classId});

  @override
  State<AddEditClassScreen> createState() => _AddEditClassScreenState();
}

class _AddEditClassScreenState extends State<AddEditClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sectionController = TextEditingController();
  final _capacityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _sectionController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final classProvider = context.read<ClassProvider>();
      final authProvider = context.read<AuthProvider>();

      final schoolClass = SchoolClass(
        id: widget.classId ?? '',
        name: _nameController.text,
        section: _sectionController.text,
        capacity: int.parse(_capacityController.text),
        teacherId: authProvider.currentUser?.id ?? '',
      );

      if (widget.classId != null) {
        classProvider.updateClass(schoolClass);
      } else {
        classProvider.addClass(schoolClass);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.classId != null
                ? 'Class updated successfully'
                : 'Class added successfully',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classId != null ? 'Edit Class' : 'Add Class'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Class Name',
                  hintText: 'Enter class name (e.g., Class A, Class 10)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.class_),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Class name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sectionController,
                decoration: InputDecoration(
                  labelText: 'Section',
                  hintText: 'Enter section (e.g., A, B, C)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.abc),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Section cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Capacity',
                  hintText: 'Enter number of students',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.people),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Capacity cannot be empty';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Capacity must be a number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(
                    widget.classId != null ? 'Update Class' : 'Add Class',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
