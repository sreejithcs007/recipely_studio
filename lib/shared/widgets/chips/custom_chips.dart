import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MultiSelectChips<T> extends StatelessWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) labelBuilder;
  final void Function(List<T>) onSelectionChanged;

  const MultiSelectChips({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.labelBuilder,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        return ChoiceChip(
          label: Text(
            labelBuilder(item),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? const Color(0xFFFAFAFA) : const Color(0xFF0F172A)),
            ),
          ),
          selected: isSelected,
          selectedColor: primaryColor,
          backgroundColor: isDark ? const Color(0xFF18181B) : const Color(0xFFF1F5F9),
          checkmarkColor: Colors.white,
          onSelected: (selected) {
            final updatedSelection = List<T>.from(selectedItems);
            if (selected) {
              updatedSelection.add(item);
            } else {
              updatedSelection.remove(item);
            }
            onSelectionChanged(updatedSelection);
          },
        );
      }).toList(),
    );
  }
}
