import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/screens/profile_setup_screen.dart';
import 'package:soberly/screens/statistics_screen.dart';
import 'package:soberly/screens/tracking_screen.dart';
import 'package:soberly/widgets/app_background.dart';
import 'package:soberly/widgets/tracking/tracking_bottom_action_bar.dart';
import 'package:soberly/widgets/app_page_header.dart';

class CalendarScreen extends StatelessWidget {
  static const String id = 'calendar_screen';

  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: TrackingBottomActionBar(
        onTrackingPressed: () =>
            Navigator.pushReplacementNamed(context, TrackingScreen.id),
        onStatisticsPressed: () =>
            Navigator.pushReplacementNamed(context, StatisticsScreen.id),
        onProfilePressed: () => Navigator.pushReplacementNamed(
          context,
          ProfileSetupScreen.id,
          arguments: true,
        ),
        selectedTab: TrackingBottomActionBarTab.calendar,
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: kEdgeInsetsAll,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(
                  title: 'Calendar',
                  subtitle: 'Review your drinking history by day',
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Calendar view coming soon.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
