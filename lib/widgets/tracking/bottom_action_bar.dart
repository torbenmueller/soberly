import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/screens/calendar_screen.dart';
import 'package:soberly/screens/custom_drinks_screen.dart';
import 'package:soberly/screens/profile_setup_screen.dart';
import 'package:soberly/screens/statistics_screen.dart';
import 'package:soberly/screens/tracking_screen.dart';
import 'package:soberly/utils/navigation_helpers.dart';

enum BottomActionBarTab { tracking, calendar, statistics, drinks, profile }

class BottomActionBar extends StatelessWidget {
  final VoidCallback? onTrackingPressed;
  final VoidCallback? onCalendarPressed;
  final VoidCallback? onStatisticsPressed;
  final VoidCallback? onDrinksPressed;
  final VoidCallback? onProfilePressed;
  final BottomActionBarTab selectedTab;
  final bool clearStackOnTabNavigation;

  const BottomActionBar({
    super.key,
    this.onTrackingPressed,
    this.onCalendarPressed,
    this.onStatisticsPressed,
    this.onDrinksPressed,
    this.onProfilePressed,
    required this.selectedTab,
    this.clearStackOnTabNavigation = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool clearStack = clearStackOnTabNavigation;

    VoidCallback? resolveTabHandler(
      BottomActionBarTab tab,
      String routeName,
      VoidCallback? override,
    ) {
      if (selectedTab == tab) {
        return null;
      }
      return override ??
          () => goToScreen(context, routeName, clearStack: clearStack);
    }

    final trackingHandler = resolveTabHandler(
      BottomActionBarTab.tracking,
      TrackingScreen.id,
      onTrackingPressed,
    );
    final calendarHandler = resolveTabHandler(
      BottomActionBarTab.calendar,
      CalendarScreen.id,
      onCalendarPressed,
    );
    final statisticsHandler = resolveTabHandler(
      BottomActionBarTab.statistics,
      StatisticsScreen.id,
      onStatisticsPressed,
    );
    final drinksHandler = resolveTabHandler(
      BottomActionBarTab.drinks,
      CustomDrinksScreen.id,
      onDrinksPressed,
    );
    final profileHandler = resolveTabHandler(
      BottomActionBarTab.profile,
      ProfileSetupScreen.id,
      onProfilePressed ??
          () => Navigator.pushNamed(
            context,
            ProfileSetupScreen.id,
            arguments: true,
          ),
    );

    return SafeArea(
      top: false,
      child: BottomAppBar(
        color: Colors.black,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                tooltip: 'Tracking',
                onPressed: trackingHandler,
                icon: Icon(
                  Icons.add,
                  color: selectedTab == BottomActionBarTab.tracking
                      ? kPrimaryColor
                      : Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Calendar',
                onPressed: calendarHandler,
                icon: Icon(
                  Icons.calendar_month,
                  color: selectedTab == BottomActionBarTab.calendar
                      ? kPrimaryColor
                      : Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Statistics',
                onPressed: statisticsHandler,
                icon: Icon(
                  Icons.show_chart,
                  color: selectedTab == BottomActionBarTab.statistics
                      ? kPrimaryColor
                      : Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Custom Drinks',
                onPressed: drinksHandler,
                icon: Icon(
                  Icons.local_bar,
                  color: selectedTab == BottomActionBarTab.drinks
                      ? kPrimaryColor
                      : Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Edit profile',
                onPressed: profileHandler,
                icon: Icon(
                  Icons.person,
                  color: selectedTab == BottomActionBarTab.profile
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
