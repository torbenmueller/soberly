import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';

enum TrackingBottomActionBarTab { tracking, calendar, statistics, profile }

class TrackingBottomActionBar extends StatelessWidget {
  final VoidCallback? onTrackingPressed;
  final VoidCallback? onCalendarPressed;
  final VoidCallback? onStatisticsPressed;
  final VoidCallback onProfilePressed;
  final TrackingBottomActionBarTab selectedTab;

  const TrackingBottomActionBar({
    super.key,
    this.onTrackingPressed,
    this.onCalendarPressed,
    this.onStatisticsPressed,
    required this.onProfilePressed,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BottomAppBar(
        color: kAppBackgroundBaseColor,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                tooltip: 'Tracking',
                onPressed: onTrackingPressed,
                icon: Icon(
                  Icons.local_bar,
                  color: selectedTab == TrackingBottomActionBarTab.tracking
                      ? kPrimaryColor
                      : Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Calendar',
                onPressed: onCalendarPressed,
                icon: Icon(
                  Icons.calendar_month,
                  color: selectedTab == TrackingBottomActionBarTab.calendar
                      ? kPrimaryColor
                      : Colors.white,
                ),
              ),
              const SizedBox(width: 56),
              IconButton(
                tooltip: 'Statistics',
                onPressed: onStatisticsPressed,
                icon: Icon(
                  Icons.query_stats,
                  color: selectedTab == TrackingBottomActionBarTab.statistics
                      ? kPrimaryColor
                      : Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Edit profile',
                onPressed: onProfilePressed,
                icon: Icon(
                  Icons.person,
                  color: selectedTab == TrackingBottomActionBarTab.profile
                      ? kPrimaryColor
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
