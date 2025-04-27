import 'package:flutter/material.dart';

class PrioritySelector extends StatelessWidget {
  final int selectedPriority;
  final ValueChanged<int> onPriorityChanged;

  const PrioritySelector({
    Key? key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Priority Level', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final priority = index + 1;
            return ChoiceChip(
              label: Text('$priority'),
              selected: selectedPriority == priority,
              onSelected: (selected) {
                if (selected) onPriorityChanged(priority);
              },
              selectedColor: Colors.blue.shade300,
            );
          }),
        ),
      ],
    );
  }
}
