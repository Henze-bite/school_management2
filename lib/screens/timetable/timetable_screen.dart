import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/timetable_model.dart';
import '../../providers/class_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/professional_widgets.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String? _selectedClassId;
  final List<TimetableEntry> _timetableEntries = [];
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  final List<String> _timeSlots = [
    '08:00-09:00',
    '09:00-10:00',
    '10:00-11:00',
    '11:00-12:00',
    '12:00-13:00',
    '13:00-14:00',
    '14:00-15:00',
    '15:00-16:00',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ClassProvider>().loadClasses();
      }
    });
  }

  TimetableEntry? _getEntryForSlot(String day, String timeSlot) {
    if (_selectedClassId == null) return null;
    try {
      return _timetableEntries.firstWhere(
        (entry) =>
            entry.classId == _selectedClassId &&
            entry.dayOfWeek == day &&
            entry.timeSlot == timeSlot,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEntryDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Class Selection
          Padding(
            padding: const EdgeInsets.all(AppPadding.lg),
            child: ProfessionalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Class',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppPadding.md),
                  Consumer<ClassProvider>(
                    builder: (context, classProvider, _) {
                      return DropdownButtonFormField<String>(
                        value: _selectedClassId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppPadding.md,
                            vertical: AppPadding.md,
                          ),
                        ),
                        hint: const Text('Select a class'),
                        items: classProvider.classes.map((cls) {
                          return DropdownMenuItem<String>(
                            value: cls.id,
                            child: Text('${cls.name} - ${cls.section}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClassId = value;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Timetable Grid
          Expanded(
            child: _selectedClassId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: AppColors.textGrey.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppPadding.lg),
                        Text(
                          'Select a class to view timetable',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: _buildTimetableGrid(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableGrid() {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.lg),
      child: Table(
        border: TableBorder.all(color: AppColors.textGrey.withOpacity(0.3)),
        columnWidths: {
          0: const FixedColumnWidth(100),
          for (int i = 1; i <= _daysOfWeek.length; i++)
            i: const FlexColumnWidth(1),
        },
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1)),
            children: [
              const TableCell(
                child: Padding(
                  padding: EdgeInsets.all(AppPadding.md),
                  child: Text(
                    'Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ..._daysOfWeek.map((day) {
                return TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPadding.md),
                    child: Text(
                      day.substring(0, 3),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            ],
          ),
          // Time Slot Rows
          ..._timeSlots.map((timeSlot) {
            return TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPadding.sm),
                    child: Text(
                      timeSlot,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ..._daysOfWeek.map((day) {
                  final entry = _getEntryForSlot(day, timeSlot);
                  final hasEntry = entry != null && entry.id.isNotEmpty;
                  return TableCell(
                    child: GestureDetector(
                      onTap: () {
                        if (hasEntry) {
                          _showEditEntryDialog(entry);
                        } else {
                          _showAddEntryDialog(day: day, timeSlot: timeSlot);
                        }
                      },
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.all(AppPadding.xs),
                        decoration: BoxDecoration(
                          color: hasEntry
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: AppColors.textGrey.withOpacity(0.2),
                          ),
                        ),
                        child: hasEntry
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    entry.subject,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    entry.room,
                                    style: const TextStyle(fontSize: 8),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showAddEntryDialog({String? day, String? timeSlot}) {
    final formKey = GlobalKey<FormState>();
    String? selectedDay = day;
    String? selectedTimeSlot = timeSlot;
    String? selectedSubject;
    String? selectedRoom;
    String? teacherId = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Timetable Entry'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: 'Day'),
                  items: _daysOfWeek.map((d) {
                    return DropdownMenuItem(value: d, child: Text(d));
                  }).toList(),
                  onChanged: (value) => selectedDay = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTimeSlot,
                  decoration: const InputDecoration(labelText: 'Time Slot'),
                  items: _timeSlots.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (value) => selectedTimeSlot = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Subject'),
                  onChanged: (value) => selectedSubject = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Room'),
                  onChanged: (value) => selectedRoom = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Teacher ID'),
                  onChanged: (value) => teacherId = value,
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
                  selectedDay != null &&
                  selectedTimeSlot != null &&
                  selectedSubject != null &&
                  selectedRoom != null &&
                  _selectedClassId != null) {
                final entry = TimetableEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  classId: _selectedClassId!,
                  subject: selectedSubject!,
                  teacherId: teacherId ?? '',
                  dayOfWeek: selectedDay!,
                  timeSlot: selectedTimeSlot!,
                  room: selectedRoom!,
                );
                setState(() {
                  _timetableEntries.add(entry);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Timetable entry added')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditEntryDialog(TimetableEntry entry) {
    // Similar to add dialog but with edit functionality
    _showAddEntryDialog(day: entry.dayOfWeek, timeSlot: entry.timeSlot);
  }
}

