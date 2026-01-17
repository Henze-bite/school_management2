import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/professional_widgets.dart';
import '../../models/attendance_model.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  State<AttendanceCalendarScreen> createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String? _selectedClassId;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<AttendanceProvider>().loadAllAttendance();
        context.read<StudentProvider>().loadStudents();
        context.read<ClassProvider>().loadClasses();
      }
    });
  }

  Map<DateTime, List<Attendance>> _getAttendanceEvents() {
    final attendanceProvider = context.read<AttendanceProvider>();
    final events = <DateTime, List<Attendance>>{};

    for (final attendance in attendanceProvider.attendances) {
      if (_selectedClassId != null &&
          attendance.classId != _selectedClassId) {
        continue;
      }

      try {
        final date = DateTime.parse(attendance.date);
        final day = DateTime(date.year, date.month, date.day);

        if (events[day] == null) {
          events[day] = [];
        }
        events[day]!.add(attendance);
      } catch (e) {
        // Skip invalid dates
      }
    }

    return events;
  }

  Color _getDateColor(DateTime date) {
    final events = _getAttendanceEvents();
    final dayEvents = events[date] ?? [];

    if (dayEvents.isEmpty) {
      return Colors.transparent;
    }

    final presentCount = dayEvents.where((e) => e.status == 'present').length;
    final absentCount = dayEvents.where((e) => e.status == 'absent').length;
    final leaveCount = dayEvents.where((e) => e.status == 'leave').length;

    if (presentCount > absentCount && presentCount > leaveCount) {
      return AppColors.success;
    } else if (absentCount > presentCount && absentCount > leaveCount) {
      return AppColors.error;
    } else if (leaveCount > 0) {
      return AppColors.warning;
    }

    return AppColors.info;
  }

  String _getAttendanceStats(DateTime date) {
    final events = _getAttendanceEvents();
    final dayEvents = events[date] ?? [];

    if (dayEvents.isEmpty) {
      return 'No attendance data';
    }

    final presentCount = dayEvents.where((e) => e.status == 'present').length;
    final absentCount = dayEvents.where((e) => e.status == 'absent').length;
    final leaveCount = dayEvents.where((e) => e.status == 'leave').length;
    final total = dayEvents.length;

    return 'Present: $presentCount | Absent: $absentCount | Leave: $leaveCount (Total: $total)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Calendar'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer3<AttendanceProvider, ClassProvider, StudentProvider>(
        builder: (context, attendanceProvider, classProvider, studentProvider,
            _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppPadding.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class Filter
                ProfessionalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter by Class',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppPadding.md),
                      DropdownButtonFormField<String>(
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
                        hint: const Text('All Classes'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Classes'),
                          ),
                          ...classProvider.classes.map((classItem) {
                            return DropdownMenuItem<String>(
                              value: classItem.id,
                              child: Text('${classItem.name} - ${classItem.section}'),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedClassId = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppPadding.lg),

                // Legend
                ProfessionalCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem('Present', AppColors.success),
                      _buildLegendItem('Absent', AppColors.error),
                      _buildLegendItem('Leave', AppColors.warning),
                    ],
                  ),
                ),
                const SizedBox(height: AppPadding.lg),

                // Calendar
                ProfessionalCard(
                  child: TableCalendar<Attendance>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    calendarFormat: _calendarFormat,
                    eventLoader: (day) {
                      final events = _getAttendanceEvents();
                      return events[day] ?? [];
                    },
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 1,
                      markerSize: 6,
                      markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      formatButtonTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          final color = _getDateColor(date);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppPadding.lg),

                // Selected Day Stats
                ProfessionalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Details - ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppPadding.md),
                      Text(
                        _getAttendanceStats(_selectedDay),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppPadding.lg),

                // Monthly Stats
                _buildMonthlyStats(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppPadding.sm),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMonthlyStats() {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, _) {
        final events = _getAttendanceEvents();
        final monthEvents = events.entries
            .where((entry) =>
                entry.key.year == _focusedDay.year &&
                entry.key.month == _focusedDay.month)
            .toList();

        int totalPresent = 0;
        int totalAbsent = 0;
        int totalLeave = 0;

        for (final entry in monthEvents) {
          for (final attendance in entry.value) {
            if (attendance.status == 'present') {
              totalPresent++;
            } else if (attendance.status == 'absent') {
              totalAbsent++;
            } else if (attendance.status == 'leave') {
              totalLeave++;
            }
          }
        }

        final total = totalPresent + totalAbsent + totalLeave;
        final percentage = total > 0 ? (totalPresent / total) * 100 : 0.0;

        return ProfessionalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Statistics - ${_getMonthName(_focusedDay.month)} ${_focusedDay.year}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppPadding.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Present', totalPresent.toString(), AppColors.success),
                  _buildStatItem('Absent', totalAbsent.toString(), AppColors.error),
                  _buildStatItem('Leave', totalLeave.toString(), AppColors.warning),
                ],
              ),
              const SizedBox(height: AppPadding.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Attendance Rate:'),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppPadding.xs),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

