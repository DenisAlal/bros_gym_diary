import 'package:flutter/material.dart';

class WeightStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  final int step;
  final int min;
  final int max;

  const WeightStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.step = 2,
    this.min = 0,
    this.max = 500,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(
          icon: Icons.remove,
          onTap: value > min ? () => onChanged(value - step) : null,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        _btn(
          icon: Icons.add,
          onTap: value < max ? () => onChanged(value + step) : null,
        ),
      ],
    );
  }

  Widget _btn({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: onTap == null ? Colors.grey.shade300 : Colors.white,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}