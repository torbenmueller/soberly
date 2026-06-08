import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/controllers/tracking_screen_controller.dart';
import 'package:soberly/models/tracking_entry.dart';
import 'package:soberly/widgets/app_background.dart';
import 'package:soberly/widgets/app_page_header.dart';
import 'package:soberly/widgets/tracking/bottom_action_bar.dart';

class StatisticsScreen extends StatefulWidget {
  static const String id = 'statistics_screen';

  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late final TrackingScreenController _controller;
  late final Future<double> _dailyLimitFuture;
  int _weekOffset = 0;
  int _monthOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = TrackingScreenController();
    _dailyLimitFuture = _controller.getDailyLimitGrams();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime _startOfWeek(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    return local.subtract(Duration(days: local.weekday - DateTime.monday));
  }

  DateTime _startOfMonth(DateTime date, int monthOffset) =>
      DateTime(date.year, date.month + monthOffset, 1);

  String _periodTitle(String unit, int offset) {
    if (offset == 0) {
      return 'This $unit';
    }
    if (offset == -1) {
      return 'Last $unit';
    }
    if (offset == 1) {
      return 'Next $unit';
    }

    final absOffset = offset.abs();
    final suffix = absOffset == 1
        ? unit.toLowerCase()
        : '${unit.toLowerCase()}s';
    return offset < 0 ? '$absOffset $suffix ago' : 'In $absOffset $suffix';
  }

  _PeriodStats _computeStats(
    List<TrackingEntry> entries,
    DateTime start,
    DateTime end,
  ) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(
      end.year,
      end.month,
      end.day,
      23,
      59,
      59,
      999,
    );

    var totalGrams = 0.0;
    var count = 0;
    final activeDays = <DateTime>{};
    final dailyTotals = <DateTime, double>{};

    for (final entry in entries) {
      final createdAt = entry.createdAt;
      if (createdAt == null) continue;

      final localDate = createdAt.toDate().toLocal();
      if (localDate.isBefore(normalizedStart) ||
          localDate.isAfter(normalizedEnd)) {
        continue;
      }

      if (entry.amount <= 0 || entry.alcoholPercent <= 0) {
        continue;
      }

      final grams = calculatePureAlcoholGrams(
        amountMl: entry.amount,
        alcoholPercent: entry.alcoholPercent,
      );
      totalGrams += grams;
      count += 1;
      final dayKey = DateTime(localDate.year, localDate.month, localDate.day);
      activeDays.add(dayKey);
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + grams;
    }

    final daysInPeriod = normalizedEnd.difference(normalizedStart).inDays + 1;
    final averagePerDay = daysInPeriod > 0 ? totalGrams / daysInPeriod : 0.0;
    final dailyGrams = List<double>.generate(daysInPeriod, (index) {
      final day = normalizedStart.add(Duration(days: index));
      return dailyTotals[DateTime(day.year, day.month, day.day)] ?? 0.0;
    });

    final soberDays = daysInPeriod - activeDays.length;

    return _PeriodStats(
      totalGrams: totalGrams,
      averagePerDay: averagePerDay,
      entriesCount: count,
      soberDays: soberDays,
      dailyGrams: dailyGrams,
    );
  }

  String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = _startOfWeek(now).add(Duration(days: _weekOffset * 7));
    final normalizedWeekEnd = weekStart.add(const Duration(days: 6));
    final monthStart = _startOfMonth(now, _monthOffset);
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);

    return Scaffold(
      bottomNavigationBar: BottomActionBar(
        selectedTab: BottomActionBarTab.statistics,
      ),
      body: AppBackground(
        child: SafeArea(
          child: FutureBuilder<double>(
            future: _dailyLimitFuture,
            builder: (context, limitSnapshot) {
              final dailyLimit = limitSnapshot.data ?? 0.0;
              return StreamBuilder<List<TrackingEntry>>(
                stream: _controller.entriesStream,
                builder: (context, snapshot) {
                  final entries = snapshot.data ?? const <TrackingEntry>[];
                  final weekStats = _computeStats(
                    entries,
                    weekStart,
                    normalizedWeekEnd,
                  );
                  final monthStats = _computeStats(
                    entries,
                    monthStart,
                    monthEnd,
                  );

                  // M T W T F S S
                  const weekdayLabels = <int, String>{
                    0: 'M',
                    1: 'T',
                    2: 'W',
                    3: 'T',
                    4: 'F',
                    5: 'S',
                    6: 'S',
                  };

                  // Show 1 on the left and last day on the right
                  final daysInMonth = monthEnd.day;
                  final monthLabels = <int, String>{
                    0: '1',
                    daysInMonth - 1: '$daysInMonth',
                  };

                  return ListView(
                    padding: kEdgeInsetsAll,
                    children: [
                      const AppPageHeader(
                        title: 'Statistics',
                        subtitle: 'See trends and insights over time',
                      ),
                      const SizedBox(height: 8),
                      _StatsCard(
                        title: _periodTitle('Week', _weekOffset),
                        dateRange:
                            '${_dateLabel(weekStart)} - ${_dateLabel(normalizedWeekEnd)}',
                        stats: weekStats,
                        dailyLimit: dailyLimit,
                        onPrevious: () => setState(() => _weekOffset -= 1),
                        onNext: _weekOffset < 0
                            ? () => setState(() => _weekOffset += 1)
                            : null,
                        chartLabels: weekdayLabels,
                      ),
                      const SizedBox(height: 12),
                      _StatsCard(
                        title: _periodTitle('Month', _monthOffset),
                        dateRange:
                            '${_dateLabel(monthStart)} - ${_dateLabel(monthEnd)}',
                        stats: monthStats,
                        dailyLimit: dailyLimit,
                        onPrevious: () => setState(() => _monthOffset -= 1),
                        onNext: _monthOffset < 0
                            ? () => setState(() => _monthOffset += 1)
                            : null,
                        chartLabels: monthLabels,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.title,
    required this.dateRange,
    required this.stats,
    required this.onPrevious,
    required this.onNext,
    required this.dailyLimit,
    this.chartLabels,
  });

  final String title;
  final String dateRange;
  final _PeriodStats stats;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final double dailyLimit;
  final Map<int, String>? chartLabels;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      color: Colors.white.withValues(alpha: 0.12),
      child: Padding(
        padding: kEdgeInsetsAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left),
                  color: Colors.white,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Previous period',
                ),
                IconButton(
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right),
                  color: Colors.white,
                  disabledColor: Colors.white54,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Next period',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dateRange,
              style: TextStyle(
                color: Colors.white.withValues(alpha: kTextOpacity),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            _DailyBarsChart(
              values: stats.dailyGrams,
              labels: chartLabels,
              dailyLimit: dailyLimit,
            ),
            const SizedBox(height: 16),
            _StatRow(
              label: 'Total alcohol',
              value: '${stats.totalGrams.toStringAsFixed(1)} g',
            ),
            _StatRow(
              label: 'Average per day',
              value: '${stats.averagePerDay.toStringAsFixed(1)} g',
            ),
            _StatRow(label: 'Entries', value: '${stats.entriesCount}'),
            _StatRow(
              label: 'Sober days',
              value: stats.soberDays > 0
                  ? '${stats.soberDays} 🏆'
                  : '${stats.soberDays}',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: kTextOpacity),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: kPrimaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyBarsChart extends StatelessWidget {
  const _DailyBarsChart({
    required this.values,
    this.labels,
    this.dailyLimit = 0.0,
  });

  final List<double> values;
  final Map<int, String>? labels;
  final double dailyLimit;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    // Use the higher of max bar or limit so the line always fits in the chart.
    final chartMax = (dailyLimit > maxValue && dailyLimit > 0)
        ? dailyLimit
        : (maxValue > 0 ? maxValue : 1.0);
    const chartHeight = 64.0;
    final hasLabels = labels != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: chartHeight,
          child: Stack(
            children: [
              // Bars
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < values.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.5),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: ((values[i] / chartMax) * (chartHeight - 2))
                                .clamp(2, chartHeight - 2),
                            decoration: BoxDecoration(
                              color: values[i] > 0
                                  ? kPrimaryColor.withValues(alpha: 0.95)
                                  : Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Dashed limit line
              if (dailyLimit > 0)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: ((dailyLimit / chartMax) * (chartHeight - 2)).clamp(
                    0,
                    chartHeight - 2,
                  ),
                  child: CustomPaint(
                    size: const Size(double.infinity, 1),
                    painter: _DashedLinePainter(),
                  ),
                ),
            ],
          ),
        ),
        if (hasLabels) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              for (var i = 0; i < values.length; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      labels![i] ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.75)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
}

class _PeriodStats {
  const _PeriodStats({
    required this.totalGrams,
    required this.averagePerDay,
    required this.entriesCount,
    required this.soberDays,
    required this.dailyGrams,
  });

  final double totalGrams;
  final double averagePerDay;
  final int entriesCount;
  final int soberDays;
  final List<double> dailyGrams;
}
