import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/controllers/tracking_screen_controller.dart';
import 'package:soberly/models/tracking_entry.dart';
import 'package:soberly/widgets/app_background.dart';
import 'package:soberly/widgets/app_page_header.dart';
import 'package:soberly/widgets/tracking/bottom_action_bar.dart';
import 'package:soberly/widgets/tracking/tracking_entry_tile.dart';

class CalendarScreen extends StatefulWidget {
  static const String id = 'calendar_screen';

  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final TrackingScreenController _controller;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = TrackingScreenController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  Map<DateTime, List<TrackingEntry>> _groupByDay(List<TrackingEntry> entries) {
    final map = <DateTime, List<TrackingEntry>>{};
    for (final e in entries) {
      final ts = e.createdAt;
      if (ts == null) continue;
      final key = _dayKey(ts.toDate().toLocal());
      (map[key] ??= []).add(e);
    }
    return map;
  }

  double _totalAlcoholGrams(List<TrackingEntry> entries) {
    return entries.fold(0.0, (total, e) {
      return total +
          calculatePureAlcoholGrams(
            amountMl: e.amount,
            alcoholPercent: e.alcoholPercent,
          );
    });
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return 'Saving...';
    final d = ts.toDate().toLocal();
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  bool get _canAddForSelectedDay {
    return _controller.isAllowedEntryDate(_selectedDay);
  }

  Future<void> _openAddDrinkSheetForSelectedDay() async {
    await _controller.showAddDrinkBottomSheet(
      context: context,
      onSubmit: () => _controller.submitEntry(context, entryDate: _selectedDay),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomActionBar(
        selectedTab: BottomActionBarTab.calendar,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _canAddForSelectedDay
          ? SizedBox.square(
              dimension: 60,
              child: FloatingActionButton(
                onPressed: _openAddDrinkSheetForSelectedDay,
                backgroundColor: kPrimaryColor,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.black, size: 30),
              ),
            )
          : null,
      body: AppBackground(
        child: SafeArea(
          child: StreamBuilder<List<TrackingEntry>>(
            stream: _controller.entriesStream,
            builder: (context, snapshot) {
              final allEntries = snapshot.data ?? [];
              final byDay = _groupByDay(allEntries);
              final selectedKey = _dayKey(_selectedDay);
              final selectedEntries = byDay[selectedKey] ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: kEdgeInsetsAll.copyWith(bottom: 0),
                    child: const AppPageHeader(
                      title: 'Calendar',
                      subtitle: 'Add drinks from up to 30 days ago',
                      bottomSpacing: 0,
                    ),
                  ),
                  _buildCalendar(byDay),
                  _buildDayHeader(selectedEntries),
                  Expanded(child: _buildDayList(selectedEntries)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(Map<DateTime, List<TrackingEntry>> byDay) {
    return TableCalendar<TrackingEntry>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      eventLoader: (day) => byDay[_dayKey(day)] ?? [],
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
      },
      onPageChanged: (focused) => setState(() => _focusedDay = focused),
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: ''},
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.white.withValues(alpha: kTextOpacity),
        ),
        weekendStyle: TextStyle(
          color: Colors.white.withValues(alpha: kTextOpacity),
        ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: const TextStyle(color: Colors.white),
        weekendTextStyle: const TextStyle(color: Colors.white),
        todayDecoration: BoxDecoration(
          color: kPrimaryColor.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(color: Colors.white),
        selectedDecoration: const BoxDecoration(
          color: kPrimaryColor,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        markerDecoration: const BoxDecoration(
          color: kPrimaryColor,
          shape: BoxShape.circle,
        ),
        markerSize: 5,
        markersMaxCount: 1,
        markerMargin: const EdgeInsets.only(top: 1),
      ),
    );
  }

  Widget _buildDayHeader(List<TrackingEntry> entries) {
    final grams = _totalAlcoholGrams(entries);
    final d = _selectedDay;
    final label =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (entries.isNotEmpty)
            Text(
              '${grams.toStringAsFixed(1)} g alcohol',
              style: const TextStyle(color: kPrimaryColor, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildDayList(List<TrackingEntry> entries) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: Center(
          child: Text(
            'No entries for this day.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: kTextOpacity),
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final drinkName = entry.drinkName.isEmpty ? '-' : entry.drinkName;
        final pureAlcohol = calculatePureAlcoholGrams(
          amountMl: entry.amount,
          alcoholPercent: entry.alcoholPercent,
        );
        final subtitle =
            '${entry.alcoholPercent.toStringAsFixed(1)}%  •  ${entry.amount} ml  •  ${pureAlcohol.toStringAsFixed(1)} g'
            '\n${_formatTime(entry.createdAt)}';
        return TrackingEntryTile(
          drinkName: drinkName,
          subtitle: subtitle,
          onEdit: () => _controller.editEntry(context, entry),
          onDelete: entry.id == null
              ? null
              : () => _controller.deleteEntry(context, entry.id!),
        );
      },
    );
  }
}
