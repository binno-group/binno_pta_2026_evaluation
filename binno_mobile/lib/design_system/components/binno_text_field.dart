import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BinnoTextField extends StatelessWidget {
  const BinnoTextField({
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.autofillHints,
    this.maxLength,
    this.onChanged,
    this.inputFormatters,
    this.enabled = true,
    super.key,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: label,
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        maxLength: maxLength,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }
}
