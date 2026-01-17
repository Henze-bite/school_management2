import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';

class AttendanceTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> attendanceData;
  final int days;

  const AttendanceTrendChart({
    required this.attendanceData,
    this.days = 7,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (attendanceData.isEmpty) {
      return const Center(
        child: Text('No attendance data available'),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppPadding.md),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.textGrey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: days > 7 ? 2 : 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < attendanceData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        attendanceData[value.toInt()]['label'] ?? '',
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: AppColors.textGrey.withOpacity(0.2),
            ),
          ),
          minX: 0,
          maxX: (attendanceData.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: attendanceData.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  (entry.value['percentage'] as num).toDouble(),
                );
              }).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GPADistributionChart extends StatelessWidget {
  final Map<String, int> gpaDistribution;

  const GPADistributionChart({
    required this.gpaDistribution,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (gpaDistribution.isEmpty) {
      return const Center(
        child: Text('No GPA data available'),
      );
    }

    final sortedEntries = gpaDistribution.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppPadding.md),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: gpaDistribution.values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.primary,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < sortedEntries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        sortedEntries[value.toInt()].key,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: AppColors.textGrey.withOpacity(0.2),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.textGrey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          barGroups: sortedEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final gpaRange = entry.value.key;
            final count = entry.value.value;
            Color barColor;
            if (gpaRange.contains('3.5') || gpaRange.contains('4.0')) {
              barColor = AppColors.success;
            } else if (gpaRange.contains('3.0') || gpaRange.contains('2.5')) {
              barColor = AppColors.warning;
            } else {
              barColor = AppColors.error;
            }
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: barColor,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class PerformancePieChart extends StatelessWidget {
  final Map<String, int> performanceData;

  const PerformancePieChart({
    required this.performanceData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (performanceData.isEmpty) {
      return const Center(
        child: Text('No performance data available'),
      );
    }

    final total = performanceData.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) {
      return const Center(
        child: Text('No performance data available'),
      );
    }

    int touchedIndex = -1;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(AppPadding.md),
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              }),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _buildSections(touchedIndex, total),
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildSections(int touchedIndex, int total) {
    final colors = [
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
    ];
    int colorIndex = 0;

    return performanceData.entries.map((entry) {
      final isTouched = touchedIndex == colorIndex;
      final percentage = (entry.value / total) * 100;
      final radius = isTouched ? 60.0 : 50.0;
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class SubjectPerformanceChart extends StatelessWidget {
  final Map<String, double> subjectAverages;

  const SubjectPerformanceChart({
    required this.subjectAverages,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (subjectAverages.isEmpty) {
      return const Center(
        child: Text('No subject data available'),
      );
    }

    final sortedEntries = subjectAverages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppPadding.md),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.primary,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < sortedEntries.length) {
                    final subject = sortedEntries[value.toInt()].key;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        subject.length > 6 ? '${subject.substring(0, 6)}...' : subject,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: AppColors.textGrey.withOpacity(0.2),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              if (value % 20 == 0) {
                return FlLine(
                  color: AppColors.textGrey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              }
              return const FlLine(color: Colors.transparent);
            },
          ),
          barGroups: sortedEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final average = entry.value.value;
            Color barColor;
            if (average >= 80) {
              barColor = AppColors.success;
            } else if (average >= 60) {
              barColor = AppColors.warning;
            } else {
              barColor = AppColors.error;
            }
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: average,
                  color: barColor,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

