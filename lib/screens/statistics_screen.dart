import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/screens/calendar_screen.dart';
import 'package:soberly/screens/profile_setup_screen.dart';
import 'package:soberly/screens/tracking_screen.dart';
import 'package:soberly/widgets/app_background.dart';
import 'package:soberly/widgets/app_page_header.dart';
import 'package:soberly/widgets/tracking/tracking_bottom_action_bar.dart';

class StatisticsScreen extends StatelessWidget {
  static const String id = 'statistics_screen';

  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: TrackingBottomActionBar(
        onTrackingPressed: () =>
            Navigator.pushReplacementNamed(context, TrackingScreen.id),
        onCalendarPressed: () =>
            Navigator.pushReplacementNamed(context, CalendarScreen.id),
        onProfilePressed: () => Navigator.pushReplacementNamed(
          context,
          ProfileSetupScreen.id,
          arguments: true,
        ),
        selectedTab: TrackingBottomActionBarTab.statistics,
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: kEdgeInsetsAll,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(
                  title: 'Statistics',
                  subtitle: 'See trends and insights over time',
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Statistics view coming soon.',
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
