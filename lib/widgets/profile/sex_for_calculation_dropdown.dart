import 'package:flutter/material.dart';
import 'package:soberly/models/sex_for_calculation.dart';
import 'package:soberly/constants.dart';

class SexForCalculationDropdown extends StatelessWidget {
  const SexForCalculationDropdown({
    super.key,
    required this.selectedSex,
    required this.isSaving,
    required this.onSelected,
  });

  final SexForCalculation? selectedSex;
  final bool isSaving;
  final ValueChanged<SexForCalculation?> onSelected;

  static const Color _dropdownBackgroundColor = Color(0xFF0D1F22);
  static const TextStyle _dropdownTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
  );

  InputDecorationTheme _buildDropdownInputDecorationTheme() {
    return InputDecorationTheme(
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: _dropdownBackgroundColor,
      enabledBorder: buildProfileOutlineInputBorder(
        color: Colors.white.withValues(alpha: 0.6),
      ),
      focusedBorder: buildProfileOutlineInputBorder(color: Colors.white),
    );
  }

  MenuStyle _buildDropdownMenuStyle(double width) {
    return MenuStyle(
      backgroundColor: const WidgetStatePropertyAll(_dropdownBackgroundColor),
      minimumSize: WidgetStatePropertyAll(Size(width, 0)),
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
    );
  }

  List<DropdownMenuEntry<SexForCalculation>> _buildEntries() {
    return SexForCalculation.values.map((item) {
      final isSelected = item == selectedSex;
      return DropdownMenuEntry<SexForCalculation>(
        value: item,
        label: item.label,
        trailingIcon: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          backgroundColor: WidgetStatePropertyAll(
            isSelected
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.transparent,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return IgnorePointer(
          ignoring: isSaving,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: isSaving ? 0.55 : 1,
            child: DropdownMenu<SexForCalculation>(
              key: ValueKey(selectedSex),
              initialSelection: selectedSex,
              width: width,
              expandedInsets: EdgeInsets.zero,
              trailingIcon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              selectedTrailingIcon: const Icon(
                Icons.arrow_drop_up,
                color: Colors.white,
              ),
              textStyle: _dropdownTextStyle,
              menuStyle: _buildDropdownMenuStyle(width),
              inputDecorationTheme: _buildDropdownInputDecorationTheme(),
              onSelected: isSaving ? null : onSelected,
              dropdownMenuEntries: _buildEntries(),
            ),
          ),
        );
      },
    );
  }
}
