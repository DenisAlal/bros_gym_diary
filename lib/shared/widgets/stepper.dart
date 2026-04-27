import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WeightInput extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  const WeightInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 500.0,
  });

  @override
  State<WeightInput> createState() => _WeightInputState();
}

class _WeightInputState extends State<WeightInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _applyValue();
      }
    });
  }

  @override
  void didUpdateWidget(covariant WeightInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value.toString() != _controller.text &&
        !_focusNode.hasFocus) {
      _controller.text = widget.value.toString();
    }
  }

  void _applyValue() {
    final parsed = double.tryParse(_controller.text);

    double newValue = parsed ?? widget.min;

    if (newValue < widget.min) newValue = widget.min;
    if (newValue > widget.max) newValue = widget.max;

    _controller.text = newValue.toString();
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
        ],
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onSubmitted: (_) => _applyValue(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}