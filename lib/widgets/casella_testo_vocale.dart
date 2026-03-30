import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CasellaTestoVocale extends StatefulWidget {
  final String label;
  final String valoreIniziale;
  final Function(String) onChanged;
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
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.valoreIniziale);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (error) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    setState(() => _speechAvailable = available);
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        localeId: 'it_IT',
        onResult: (result) {
          final testo = result.recognizedWords;
          final vecchio = _controller.text;
          final nuovoTesto = vecchio.isNotEmpty ? '$vecchio $testo' : testo;
          _controller.text = nuovoTesto;
          _controller.selection = TextSelection.collapsed(offset: nuovoTesto.length);
          widget.onChanged(nuovoTesto);
        },
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        suffixIcon: _speechAvailable
            ? IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : Colors.grey,
                ),
                tooltip: _isListening ? 'Stop dettatura' : 'Dettatura vocale',
                onPressed: _toggleListening,
              )
            : null,
      ),
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
    );
  }
}
