import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/widgets/app_background.dart';
import 'package:soberly/widgets/tracking/bottom_action_bar.dart';
import 'package:soberly/widgets/app_page_header.dart';

class CustomDrinksScreen extends StatelessWidget {
  static const String id = 'custom_drinks_screen';

  const CustomDrinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomActionBar(
        selectedTab: BottomActionBarTab.drinks,
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: kEdgeInsetsAll,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(
                  title: 'Custom Drinks',
                  subtitle: 'Create and edit your custom drinks',
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Custom Drinks view coming soon.',
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
