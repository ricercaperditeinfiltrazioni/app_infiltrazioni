import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  late stt.SpeechToText _speech;
  bool _isListening = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _controller = TextEditingController(text: widget.valoreIniziale);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ascolta() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => print('Errore vocale: $val'),
      );
      
      if (available) {
        setState(() => _isListening = true);
        
        // Salva il testo che c'era già prima di parlare
        String testoPrecedente = _controller.text;
        if (testoPrecedente.isNotEmpty && !testoPrecedente.endsWith(' ')) {
          testoPrecedente += ' ';
        }
        
        _speech.listen(
          localeId: 'it_IT', // Forza lingua italiana
          onResult: (val) {
            setState(() {
              // Unisce il testo vecchio con quello appena dettato
              _controller.text = testoPrecedente + val.recognizedWords;
              // Sposta il cursore alla fine
              _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
              // Salva i dati
              widget.onChanged(_controller.text);
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged, // Se l'utente scrive a mano
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        // Il bottone del microfono compare dentro la casella di testo a destra
        suffixIcon: IconButton(
          icon: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: _isListening ? Colors.red : Colors.blue,
            size: 30,
          ),
          onPressed: _ascolta,
        ),
      ),
    );
  }
}
