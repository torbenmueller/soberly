import 'package:flutter/material.dart';
import 'package:soberly/components/app_button.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/models/custom_drink.dart';

class CustomDrinkEditorSheet extends StatefulWidget {
  const CustomDrinkEditorSheet({
    super.key,
    this.initialDrink,
    required this.onSubmit,
  });

  final CustomDrink? initialDrink;
  final Future<bool> Function(CustomDrink drink) onSubmit;

  @override
  State<CustomDrinkEditorSheet> createState() => _CustomDrinkEditorSheetState();
}

class _CustomDrinkEditorSheetState extends State<CustomDrinkEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _alcoholController;
  late final TextEditingController _amountController;
  late String _selectedIconKey;
  late int _selectedColorValue;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final initialDrink = widget.initialDrink;
    _nameController = TextEditingController(text: initialDrink?.name ?? '');
    _alcoholController = TextEditingController(
      text: _formatAlcoholPercent(initialDrink?.alcoholPercent),
    );
    _amountController = TextEditingController(
      text: initialDrink?.amountMl.toString() ?? '',
    );
    _selectedIconKey =
        initialDrink?.iconKey ?? customDrinkIconOptions.first.key;
    _selectedColorValue =
        initialDrink?.colorValue ??
        customDrinkColorOptions.first.color.toARGB32();
  }

  String _formatAlcoholPercent(double? value) {
    if (value == null) {
      return '';
    }
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  Color _foregroundFor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Future<void> _handleSubmit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final drink = CustomDrink(
      id: widget.initialDrink?.id,
      displayOrder: widget.initialDrink?.displayOrder,
      name: _nameController.text.trim(),
      alcoholPercent: double.parse(
        _alcoholController.text.trim().replaceAll(',', '.'),
      ),
      amountMl: int.parse(_amountController.text.trim()),
      iconKey: _selectedIconKey,
      colorValue: _selectedColorValue,
      createdAt: widget.initialDrink?.createdAt,
    );

    final saved = await widget.onSubmit(drink);
    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (saved) {
      FocusScope.of(context).unfocus();
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _alcoholController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIcon = customDrinkIconOptionFromKey(_selectedIconKey);
    final selectedColor = customDrinkColorOptionFromValue(
      _selectedColorValue,
    ).color;
    final fg = _foregroundFor(selectedColor);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: kEdgeInsetsAll,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      widget.initialDrink == null
                          ? 'Add Custom Drink'
                          : 'Edit Custom Drink',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selectedColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: selectedColor,
                        child: Icon(selectedIcon.icon, color: fg),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.trim().isEmpty
                                  ? 'Drink preview'
                                  : _nameController.text.trim(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_amountController.text.trim().isEmpty ? '-' : _amountController.text.trim()} ml  •  ${_alcoholController.text.trim().isEmpty ? '-' : _alcoholController.text.trim()}%',
                              style: TextStyle(
                                color: Colors.black.withValues(
                                  alpha: kTextOpacity,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Drink Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a drink name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _alcoholController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Alcohol %',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    final text = value?.trim().replaceAll(',', '.') ?? '';
                    if (text.isEmpty) {
                      return 'Please enter alcohol percentage.';
                    }
                    final v = double.tryParse(text);
                    if (v == null || v < 0 || v > 100) {
                      return 'Enter a value between 0 and 100.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (ml)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Please enter an amount.';
                    }
                    final v = int.tryParse(text);
                    if (v == null || v <= 0) {
                      return 'Enter a whole number greater than 0.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose an icon',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: kTextOpacity),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in customDrinkIconOptions)
                      ChoiceChip(
                        backgroundColor: const Color(0xFFE0E0E0),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(option.icon, size: 18),
                            const SizedBox(width: 6),
                            Text(option.label),
                          ],
                        ),
                        selected: _selectedIconKey == option.key,
                        onSelected: (_) =>
                            setState(() => _selectedIconKey = option.key),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose a color',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: kTextOpacity),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in customDrinkColorOptions)
                      ChoiceChip(
                        backgroundColor: const Color(0xFFE0E0E0),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: option.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(option.label),
                          ],
                        ),
                        selected:
                            _selectedColorValue == option.color.toARGB32(),
                        onSelected: (_) => setState(
                          () => _selectedColorValue = option.color.toARGB32(),
                        ),
                      ),
                  ],
                ),
                AppButton(
                  title: _isSubmitting ? 'Saving...' : 'Save Custom Drink',
                  color: kPrimaryColor,
                  onPressed: _isSubmitting ? null : _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
