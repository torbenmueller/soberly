import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';

class TrackingBottomActionBar extends StatelessWidget {
  final VoidCallback? onTrackingPressed;
  final VoidCallback? onCalendarPressed;
  final VoidCallback? onStatisticsPressed;
  final VoidCallback onProfilePressed;
  final bool isTrackingSelected;
  final bool isProfileSelected;

  const TrackingBottomActionBar({
    super.key,
    this.onTrackingPressed,
    this.onCalendarPressed,
    this.onStatisticsPressed,
    required this.onProfilePressed,
    this.isTrackingSelected = false,
    this.isProfileSelected = false,
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
                  color: isTrackingSelected ? kPrimaryColor : Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Calendar coming soon',
                onPressed: onCalendarPressed,
                icon: const Icon(Icons.calendar_month, color: Colors.white),
              ),
              const SizedBox(width: 56),
              IconButton(
                tooltip: 'Statistics coming soon',
                onPressed: onStatisticsPressed,
                icon: const Icon(Icons.query_stats, color: Colors.white),
              ),
              IconButton(
                tooltip: 'Edit profile',
                onPressed: onProfilePressed,
                icon: Icon(
                  Icons.person,
                  color: isProfileSelected ? kPrimaryColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
