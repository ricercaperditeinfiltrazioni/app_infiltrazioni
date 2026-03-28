import 'package:flutter/material.dart';

class CasellaTestoVocale extends StatefulWidget {
  final String label;
  final String valoreIniziale;
  final ValueChanged<String> onChanged;
  final int maxLines;

  const CasellaTestoVocale({
    super.key,
    required this.label,
    required this.valoreIniziale,
    required this.onChanged,
    this.maxLines = 3,
  });

  @override
  State<CasellaTestoVocale> createState() => _CasellaTestoVocaleState();
}

class _CasellaTestoVocaleState extends State<CasellaTestoVocale> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.valoreIniziale);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        hintText: 'Scrivi qui o usa il microfono della tastiera...',
      ),
      onChanged: widget.onChanged,
    );
  }
}
